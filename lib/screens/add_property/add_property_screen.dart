import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/location_helper.dart';
import '../../data/repositories/property_repository.dart';
import '../property_map/interactive_map_picker.dart';
import 'upload_images_screen.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  int _currentStep = 0;
  late PageController _pageController;

  // ── Step 1: Basic Info ──
  String _propertyName = '';
  String _propertyDescription = '';
  String _propertyType = 'شقة';
  String _propertyCity = 'الرياض';
  String _furnishing = 'مفروش';
  String _area = '';
  String _beds = '';
  String _baths = '';
  String _kitchens = '';
  String _guests = '';
  String _dailyPrice = '';
  String _monthlyPrice = '';
  String _yearlyPrice = '';
  String _period = 'يومياً';

  // ── Step 2: Location ──
  String _address = '';
  String _buildingNumber = '';
  String _floor = '';
  LatLng? _selectedLocation;

  // ── Step 3: Amenities ──
  final Set<String> _primaryAmenities = {};
  final Set<String> _secondaryAmenities = {};
  final Set<String> _kitchenAmenities = {};
  final Set<String> _bathroomAmenities = {};
  final Set<String> _propertyFeatures = {};

  // ── الصور المختارة ──
  final List<String> _selectedImagePaths = [];
  String? _selectedVideoPath;

  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Get.back();
    }
  }

  // ═══════════════════════════════════════════════
  //  Maps
  // ═══════════════════════════════════════════════

  static const Map<String, String> _typeMap = {
    'شقة': 'apartment', 'فيلا': 'villa', 'مكتب': 'office', 'دوبلكس': 'duplex',
    'استوديو': 'studio', 'بنتهاوس': 'penthouse', 'تجاري': 'commercial', 'مزرعة': 'farm',
  };

  static const Map<String, String> _cityMap = {
    'الرياض': 'Riyadh', 'جدة': 'Jeddah', 'الدمام': 'Dammam', 'الخبر': 'Khobar',
    'مكة': 'Makkah', 'المدينة': 'Madinah', 'أبها': 'Abha', 'تبوك': 'Tabuk',
  };

  static const Map<String, String> _furnishingMap = {
    'مفروش': 'furnished', 'غير مفروش': 'unfurnished', 'شبه مفروش': 'semi-furnished',
  };

  static const Map<String, String> _periodMap = {
    'يومياً': 'daily', 'شهرياً': 'monthly', 'سنوياً': 'yearly',
  };

  // ═══════════════════════════════════════════════
  //  Publish
  // ═══════════════════════════════════════════════

  Future<void> _publish() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_propertyName.trim().isEmpty || _propertyDescription.trim().isEmpty) {
      Get.snackbar('معلومات ناقصة', 'أدخل اسم العقار ووصفه',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.primary, colorText: AppColors.white);
      return;
    }
    setState(() => _publishing = true);
    debugPrint('📍 _publish: selectedLocation=$_selectedLocation');
    debugPrint('📍 _publish: lat=${_selectedLocation?.latitude} lng=${_selectedLocation?.longitude}');
    try {
      final allAmenities = {..._primaryAmenities, ..._secondaryAmenities};

      // التأكد من وجود إحداثيات الموقع دائماً
      LatLng? finalCoords = _selectedLocation;
      if (finalCoords == null) {
        if (_address.trim().isNotEmpty) {
          finalCoords = await LocationHelper.geocodeAddress(_address);
        }
        finalCoords ??= LocationHelper.getFallbackCoords(_propertyCity);
      }

      final created = await PropertyRepository().createOwnerProperty(
        title: _propertyName.trim(),
        description: _propertyDescription.trim(),
        location: (_propertyCity + (_address.isNotEmpty ? '، $_address' : '')).trim(),
        city: _cityMap[_propertyCity] ?? 'Riyadh',
        address: _address.trim().isNotEmpty ? _address.trim() : null,
        propertyType: _typeMap[_propertyType] ?? 'apartment',
        furnishing: _furnishingMap[_furnishing] ?? 'furnished',
        area: num.tryParse(_area) ?? 0,
        prices: {
          'daily': num.tryParse(_dailyPrice.replaceAll(',', '')) ?? 0,
          'monthly': num.tryParse(_monthlyPrice.replaceAll(',', '')) ?? 0,
          'yearly': num.tryParse(_yearlyPrice.replaceAll(',', '')) ?? 0,
        },
        period: _periodMap[_period] ?? 'daily',
        status: 'available',
        beds: int.tryParse(_beds) ?? 1,
        baths: int.tryParse(_baths) ?? 1,
        kitchens: int.tryParse(_kitchens) ?? 0,
        guests: int.tryParse(_guests) ?? 1,
        floor: _floor.isEmpty ? null : _floor,
        buildingNumber: _buildingNumber.isEmpty ? null : _buildingNumber,
        amenities: allAmenities.toList(),
        primaryAmenities: _primaryAmenities.toList(),
        secondaryAmenities: _secondaryAmenities.toList(),
        kitchenAmenities: _kitchenAmenities.toList(),
        bathroomAmenities: _bathroomAmenities.toList(),
        propertyFeatures: _propertyFeatures.toList(),
        cancellationPolicy: 'Flexible',
        latitude: finalCoords?.latitude,
        longitude: finalCoords?.longitude,
      );

      final ctrl = Get.find<AppController>();
      ctrl.ownerProperties.insert(0, created);
      AuthController.instance.fetchOwnerStats();
      ctrl.fetchOwnerMyProperties(silent: true);

      // رفع الصور المختارة إن وُجدت
      if (created.id != null && _selectedImagePaths.isNotEmpty) {
        await PropertyRepository().uploadPropertyImages(
          propertyId: created.id!,
          files: _selectedImagePaths,
        );
      }

      // رفع الفيديو إن وُجد
      if (created.id != null && _selectedVideoPath != null) {
        await PropertyRepository().uploadPropertyVideo(
          propertyId: created.id!,
          filePath: _selectedVideoPath!,
        );
      }

      Get.snackbar('تم النشر', 'تم إضافة العقار بنجاح',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.primary, colorText: AppColors.white);

      // الانتقال لشاشة رفع الصور والفيديو
      if (created.id != null) {
        Get.off(() => UploadImagesScreen(propertyId: created.id!, propertyTitle: created.title));
      } else {
        Get.back();
      }
    } catch (e, stack) {
      debugPrint('❌ publish error: $e');
      debugPrint('Stack: $stack');
      String msg = 'تعذر إرسال العقار، حاول مرة أخرى.';
      final errStr = e.toString();
      if (errStr.contains('FormatException')) {
        msg = 'استجابة غير متوقعة من السيرفر.';
      } else if (errStr.contains('422')) {
        msg = 'بيانات غير صالحة — تأكد من ملء كل الحقول المطلوبة.';
      } else if (errStr.contains('401')) {
        msg = 'انتهت صلاحية تسجيل الدخول.';
      } else if (errStr.contains('SocketException') || errStr.contains('timeout')) {
        msg = 'خطأ في الاتصال بالسيرفر.';
      }
      Get.snackbar('فشل النشر', msg,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFC62828), colorText: AppColors.white);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  // ═══════════════════════════════════════════════
  //  Build
  // ═══════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fieldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('إضافة عقار جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.black), onPressed: _back),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 5,
                    backgroundColor: AppColors.fieldBorder,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text('الخطوة ${_currentStep + 1} من 5', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _StepInfo(
                  propertyName: _propertyName, propertyDescription: _propertyDescription,
                  propertyType: _propertyType, propertyCity: _propertyCity,
                  furnishing: _furnishing, area: _area,
                  beds: _beds, baths: _baths, kitchens: _kitchens, guests: _guests,
                  dailyPrice: _dailyPrice, monthlyPrice: _monthlyPrice, yearlyPrice: _yearlyPrice,
                  period: _period,
                  onNameChanged: (v) => setState(() => _propertyName = v),
                  onDescriptionChanged: (v) => setState(() => _propertyDescription = v),
                  onTypeChanged: (v) => setState(() => _propertyType = v),
                  onCityChanged: (v) => setState(() => _propertyCity = v),
                  onFurnishingChanged: (v) => setState(() => _furnishing = v),
                  onAreaChanged: (v) => setState(() => _area = v),
                  onBedsChanged: (v) => setState(() => _beds = v),
                  onBathsChanged: (v) => setState(() => _baths = v),
                  onKitchensChanged: (v) => setState(() => _kitchens = v),
                  onGuestsChanged: (v) => setState(() => _guests = v),
                  onDailyPriceChanged: (v) => setState(() => _dailyPrice = v),
                  onMonthlyPriceChanged: (v) => setState(() => _monthlyPrice = v),
                  onYearlyPriceChanged: (v) => setState(() => _yearlyPrice = v),
                  onPeriodChanged: (v) => setState(() => _period = v),
                  onNext: _next,
                ),
                _StepLocation(
                  address: _address, buildingNumber: _buildingNumber, floor: _floor,
                  selectedLocation: _selectedLocation,
                  onAddressChanged: (v) => setState(() => _address = v),
                  onBuildingChanged: (v) => setState(() => _buildingNumber = v),
                  onFloorChanged: (v) => setState(() => _floor = v),
                  onLocationPicked: (ll) => setState(() => _selectedLocation = ll),
                  onNext: _next,
                ),
                _StepAmenities(
                  primaryAmenities: _primaryAmenities, secondaryAmenities: _secondaryAmenities,
                  kitchenAmenities: _kitchenAmenities, bathroomAmenities: _bathroomAmenities,
                  propertyFeatures: _propertyFeatures,
                  onToggle: (set, label) => setState(() {
                    if (set.contains(label)) { set.remove(label); } else { set.add(label); }
                  }),
                  onNext: _next,
                ),
                _StepPhotos(
                  selectedPaths: _selectedImagePaths,
                  selectedVideoPath: _selectedVideoPath,
                  onAdd: () async {
                    final picker = ImagePicker();
                    final images = await picker.pickMultiImage(imageQuality: 85);
                    if (images.isNotEmpty) {
                      setState(() => _selectedImagePaths.addAll(images.map((e) => e.path)));
                    }
                  },
                  onAddVideo: () async {
                    final picker = ImagePicker();
                    final video = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 5));
                    if (video != null) {
                      final file = File(video.path);
                      final sizeMb = await file.length() / (1024 * 1024);
                      if (sizeMb > 50) {
                        Get.snackbar('ملف كبير جداً', 'الحد الأقصى 50 ميجا',
                            snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFFF6F00), colorText: Colors.white);
                        return;
                      }
                      setState(() => _selectedVideoPath = video.path);
                    }
                  },
                  onRemove: (i) => setState(() => _selectedImagePaths.removeAt(i)),
                  onRemoveVideo: () => setState(() => _selectedVideoPath = null),
                  onNext: _next,
                ),
                _StepReview(
                  onPublish: _publish, publishing: _publishing,
                  propertyName: _propertyName, propertyType: _propertyType,
                  propertyCity: _propertyCity, furnishing: _furnishing, area: _area,
                  beds: _beds, baths: _baths, kitchens: _kitchens, guests: _guests,
                  dailyPrice: _dailyPrice, monthlyPrice: _monthlyPrice, yearlyPrice: _yearlyPrice,
                  period: _period, address: _address,
                  primaryAmenities: _primaryAmenities, secondaryAmenities: _secondaryAmenities,
                  kitchenAmenities: _kitchenAmenities, bathroomAmenities: _bathroomAmenities,
                  propertyFeatures: _propertyFeatures,
                  locationPicked: _selectedLocation != null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Step 1: Basic Info
// ═══════════════════════════════════════════════

class _StepInfo extends StatelessWidget {
  final String propertyName, propertyDescription, propertyType, propertyCity;
  final String furnishing, area, beds, baths, kitchens, guests;
  final String dailyPrice, monthlyPrice, yearlyPrice, period;
  final ValueChanged<String> onNameChanged, onDescriptionChanged, onTypeChanged, onCityChanged;
  final ValueChanged<String> onFurnishingChanged, onAreaChanged;
  final ValueChanged<String> onBedsChanged, onBathsChanged, onKitchensChanged, onGuestsChanged;
  final ValueChanged<String> onDailyPriceChanged, onMonthlyPriceChanged, onYearlyPriceChanged;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onNext;

  const _StepInfo({
    required this.propertyName, required this.propertyDescription,
    required this.propertyType, required this.propertyCity,
    required this.furnishing, required this.area,
    required this.beds, required this.baths, required this.kitchens, required this.guests,
    required this.dailyPrice, required this.monthlyPrice, required this.yearlyPrice,
    required this.period,
    required this.onNameChanged, required this.onDescriptionChanged,
    required this.onTypeChanged, required this.onCityChanged,
    required this.onFurnishingChanged, required this.onAreaChanged,
    required this.onBedsChanged, required this.onBathsChanged, required this.onKitchensChanged, required this.onGuestsChanged,
    required this.onDailyPriceChanged, required this.onMonthlyPriceChanged, required this.onYearlyPriceChanged,
    required this.onPeriodChanged, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _Card(
            icon: Icons.help_outline, iconBg: AppColors.fieldBorder, title: 'معلومات العقار',
            children: [
              _InputLabel(text: 'اسم العقار'),
              const SizedBox(height: 6),
              _FormField(hint: 'مثال: شقة فاخرة في المعادي', onChanged: onNameChanged),
              const SizedBox(height: 16),
              _InputLabel(text: 'وصف العقار'),
              const SizedBox(height: 6),
              _FormField(hint: 'اكتب وصفاً مفصلاً للعقار...', maxLines: 4, onChanged: onDescriptionChanged),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _DropdownColumn(label: 'نوع العقار', value: propertyType,
                    items: const ['شقة', 'فيلا', 'مكتب', 'دوبلكس', 'استوديو', 'بنتهاوس', 'تجاري', 'مزرعة'], onChanged: onTypeChanged)),
                const SizedBox(width: 12),
                Expanded(child: _DropdownColumn(label: 'المدينة', value: propertyCity,
                    items: const ['الرياض', 'جدة', 'الدمام', 'الخبر', 'مكة', 'المدينة', 'أبها', 'تبوك'], onChanged: onCityChanged)),
              ]),
              const SizedBox(height: 16),
              _InputLabel(text: 'حالة التأثيث'),
              const SizedBox(height: 6),
              _DropdownField(value: furnishing, items: const ['مفروش', 'غير مفروش', 'شبه مفروش'], onChanged: onFurnishingChanged),
              const SizedBox(height: 16),
              _InputLabel(text: 'المساحة (م²)'),
              const SizedBox(height: 6),
              _FormField(hint: '120', keyboardType: TextInputType.number, onChanged: onAreaChanged),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _CountField(label: 'غرف النوم', value: beds, onChanged: onBedsChanged)),
                const SizedBox(width: 10),
                Expanded(child: _CountField(label: 'الحمامات', value: baths, onChanged: onBathsChanged)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _CountField(label: 'المطابخ', value: kitchens, onChanged: onKitchensChanged)),
                const SizedBox(width: 10),
                Expanded(child: _CountField(label: 'الضيوف', value: guests, onChanged: onGuestsChanged)),
              ]),
              const SizedBox(height: 16),
              _InputLabel(text: 'فترة الإيجار'),
              const SizedBox(height: 6),
              _DropdownField(value: period, items: const ['يومياً', 'شهرياً', 'سنوياً'], onChanged: onPeriodChanged),
              const SizedBox(height: 16),
              _InputLabel(text: 'الأسعار (SAR)'),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: _PriceField(label: 'يومي', value: dailyPrice, onChanged: onDailyPriceChanged)),
                const SizedBox(width: 10),
                Expanded(child: _PriceField(label: 'شهري', value: monthlyPrice, onChanged: onMonthlyPriceChanged)),
                const SizedBox(width: 10),
                Expanded(child: _PriceField(label: 'سنوي', value: yearlyPrice, onChanged: onYearlyPriceChanged)),
              ]),
            ],
          ),
          const SizedBox(height: 24),
          _NextButton(label: 'التالي: الموقع', onPressed: onNext),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Step 2: Location + Map
// ═══════════════════════════════════════════════

/// الحصول على موقع الجهاز الحالي.
Future<void> _pickCurrentLocation(BuildContext context, ValueChanged<LatLng> onPicked) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        onPicked(LatLng(lastPos.latitude, lastPos.longitude));
        Get.snackbar('تم تحديد الموقع', 'تم استخدام آخر موقع معروف',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.primary, colorText: Colors.white);
        return;
      }
      Get.snackbar(
          'الموقع غير متاح',
          'يمكنك تحديد الموقع بالبحث عن العنوان',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1565C0),
          colorText: Colors.white,
          duration: const Duration(seconds: 4));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('الصلاحية مرفوضة', 'يرجى منح صلاحية الوصول للموقع',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFE65100), colorText: Colors.white);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('الصلاحية مرفوضة نهائياً', 'افتح إعدادات التطبيق وفعّل صلاحية الموقع',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFC62828), colorText: Colors.white);
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
    onPicked(LatLng(position.latitude, position.longitude));

    Get.snackbar('تم تحديد الموقع', 'موقعك الحالي تم تحديده',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.primary, colorText: Colors.white);
  } catch (e) {
    Get.snackbar('خطأ', 'تعذر الحصول على الموقع الحالي',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFC62828), colorText: Colors.white);
  }
}

class _StepLocation extends StatefulWidget {
  final String address, buildingNumber, floor;
  final LatLng? selectedLocation;
  final ValueChanged<String> onAddressChanged, onBuildingChanged, onFloorChanged;
  final ValueChanged<LatLng> onLocationPicked;
  final VoidCallback onNext;

  const _StepLocation({
    required this.address, required this.buildingNumber, required this.floor,
    required this.selectedLocation,
    required this.onAddressChanged, required this.onBuildingChanged, required this.onFloorChanged,
    required this.onLocationPicked, required this.onNext,
  });

  @override
  State<_StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<_StepLocation> {
  Timer? _debounce;
  bool _searching = false;
  final TextEditingController _addressCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addressCtl.text = widget.address;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressCtl.dispose();
    super.dispose();
  }

  void _onAddressTyped(String value) {
    widget.onAddressChanged(value);
    _debounce?.cancel();
    if (value.trim().length >= 3) {
      _debounce = Timer(const Duration(milliseconds: 900), () {
        _geocode(value.trim());
      });
    }
  }

  void _onSearch() {
    final query = _addressCtl.text.trim();
    if (query.isNotEmpty) {
      _debounce?.cancel();
      _geocode(query);
    }
  }

  Future<void> _geocode(String query) async {
    if (!mounted) return;
    setState(() => _searching = true);
    final coords = await LocationHelper.geocodeAddress(query);
    if (!mounted) return;
    setState(() => _searching = false);

    if (coords != null) {
      widget.onLocationPicked(coords);
      Get.snackbar('تم تحديد الموقع', 'تم العثور على الإحداثيات بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
    } else {
      Get.snackbar('لم يتم العثور', 'يمكنك فتح الخريطة لتحديد الموقع يدوياً',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF8F00),
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
    }
  }

  Future<void> _openInteractiveMapPicker() async {
    final result = await Navigator.push<MapLocationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => InteractiveMapPickerScreen(
          initialLocation: widget.selectedLocation,
          initialAddress: _addressCtl.text.isNotEmpty ? _addressCtl.text : null,
        ),
      ),
    );

    if (result != null) {
      widget.onLocationPicked(result.coordinates);
      if (result.address != null && result.address!.isNotEmpty) {
        _addressCtl.text = result.address!;
        widget.onAddressChanged(result.address!);
      }
      if (mounted) setState(() {});
    }
  }

  String _staticMapUrl(LatLng ll) {
    final lat = ll.latitude.toStringAsFixed(5);
    final lon = ll.longitude.toStringAsFixed(5);
    return 'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=$lat,$lon&zoom=16&size=600x300&maptype=mapnik'
        '&markers=$lat,$lon,red-pushpin';
  }

  Future<void> _handleNext() async {
    if (widget.selectedLocation == null && _addressCtl.text.trim().isNotEmpty) {
      final coords = await LocationHelper.geocodeAddress(_addressCtl.text.trim());
      if (coords != null) {
        widget.onLocationPicked(coords);
      }
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocation = widget.selectedLocation;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _Card(
            icon: Icons.location_on, iconBg: AppColors.primary, title: 'الموقع والخريطة',
            children: [
              // ── زر فتح الخريطة التفاعلية ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openInteractiveMapPicker,
                  icon: const Icon(Icons.map_outlined, size: 20, color: Colors.white),
                  label: const Text(
                    'تحديد الموقع على الخريطة التفاعلية',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── معاينة الخريطة أو حقل البحث ──
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _openInteractiveMapPicker,
                          child: selectedLocation != null
                              ? Image.network(
                                  _staticMapUrl(selectedLocation),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (c, child, p) => p == null
                                      ? child
                                      : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  errorBuilder: (c, e, s) => Container(
                                    color: const Color(0xFFE8F5E9),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.location_on, size: 48, color: AppColors.primary),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}',
                                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text('اضغط لتغيير الموقع على الخريطة', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFFF5F5F5),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.add_location_alt_outlined, size: 48, color: AppColors.primary),
                                        const SizedBox(height: 8),
                                        const Text('اضغط هنا لفتح الخريطة واختيار الموقع',
                                            style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600, fontSize: 13)),
                                        const SizedBox(height: 4),
                                        Text('أو اكتب العنوان في مربع البحث أعلاه',
                                            style: TextStyle(color: AppColors.grey.withValues(alpha: 0.8), fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 10, left: 10, right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: TextField(
                            controller: _addressCtl,
                            onChanged: _onAddressTyped,
                            onSubmitted: (_) => _onSearch(),
                            textDirection: TextDirection.rtl,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'ابحث عن العنوان أو الحي...',
                              hintTextDirection: TextDirection.rtl,
                              hintStyle: TextStyle(fontSize: 13, color: AppColors.grey.withValues(alpha: 0.5)),
                              prefixIcon: _searching
                                  ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                                  : IconButton(
                                      icon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                                      onPressed: _onSearch,
                                    ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.my_location, color: AppColors.primary, size: 20),
                                onPressed: () => _pickCurrentLocation(context, (ll) {
                                  widget.onLocationPicked(ll);
                                  LocationHelper.reverseGeocode(ll.latitude, ll.longitude).then((addr) {
                                    if (addr != null && mounted) {
                                      _addressCtl.text = addr;
                                      widget.onAddressChanged(addr);
                                    }
                                  });
                                }),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      if (selectedLocation != null)
                        Positioned(
                          bottom: 10, left: 10, right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(
                                  'تم التحديد: ${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                                )),
                                const Icon(Icons.edit, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _InputLabel(text: 'رقم المبنى'),
                  const SizedBox(height: 6),
                  _FormField(hint: '12', keyboardType: TextInputType.number, onChanged: widget.onBuildingChanged, initialValue: widget.buildingNumber),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _InputLabel(text: 'الطابق'),
                  const SizedBox(height: 6),
                  _FormField(hint: '3', keyboardType: TextInputType.number, onChanged: widget.onFloorChanged, initialValue: widget.floor),
                ])),
              ]),
            ],
          ),
          const SizedBox(height: 24),
          _NextButton(label: 'التالي: المرافق', onPressed: _handleNext),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Step 3: Amenities (Categorized)
// ═══════════════════════════════════════════════

class _StepAmenities extends StatelessWidget {
  final Set<String> primaryAmenities, secondaryAmenities, kitchenAmenities, bathroomAmenities, propertyFeatures;
  final void Function(Set<String>, String) onToggle;
  final VoidCallback onNext;

  const _StepAmenities({
    required this.primaryAmenities, required this.secondaryAmenities,
    required this.kitchenAmenities, required this.bathroomAmenities,
    required this.propertyFeatures, required this.onToggle, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _Card(
            icon: Icons.grid_view, iconBg: AppColors.primary, title: 'المرافق والمميزات',
            children: [
              _AmenitySection(
                title: 'المرافق الأساسية',
                icon: Icons.star_outline,
                items: const ['WiFi', 'Parking', 'AC', 'Elevator', 'Gym', 'Pool', 'Security', 'Laundry'],
                selected: primaryAmenities, onToggle: onToggle,
              ),
              const SizedBox(height: 16),
              _AmenitySection(
                title: 'المرافق الثانوية',
                icon: Icons.add_circle_outline,
                items: const ['Storage', 'Garden', 'BBQ', 'Playground', 'Concierge', 'Balcony'],
                selected: secondaryAmenities, onToggle: onToggle,
              ),
              const SizedBox(height: 16),
              _AmenitySection(
                title: 'مرافق المطبخ',
                icon: Icons.kitchen,
                items: const ['Oven', 'Refrigerator', 'Microwave', 'Dishwasher', 'Washing Machine', 'Stove'],
                selected: kitchenAmenities, onToggle: onToggle,
              ),
              const SizedBox(height: 16),
              _AmenitySection(
                title: 'مرافق الحمام',
                icon: Icons.bathtub_outlined,
                items: const ['Towels', 'Hair Dryer', 'Shower', 'Bathtub', 'Heated Floor'],
                selected: bathroomAmenities, onToggle: onToggle,
              ),
              const SizedBox(height: 16),
              _AmenitySection(
                title: 'مميزات العقار',
                icon: Icons.home_outlined,
                items: const ['City view', 'Sea view', 'Balcony', 'Terrace', 'Storage Room', 'Furnished', 'Smart Home'],
                selected: propertyFeatures, onToggle: onToggle,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _NextButton(label: 'التالي: المراجعة', onPressed: onNext),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _AmenitySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final Set<String> selected;
  final void Function(Set<String>, String) onToggle;

  const _AmenitySection({
    required this.title, required this.icon, required this.items,
    required this.selected, required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        ]),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: items.map((item) {
            final isSelected = selected.contains(item);
            return GestureDetector(
              onTap: () => onToggle(selected, item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.fieldBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 18, color: isSelected ? AppColors.primary : AppColors.grey),
                    const SizedBox(width: 6),
                    Text(item, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.grey)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Step 4: Photos
// ═══════════════════════════════════════════════

class _StepPhotos extends StatelessWidget {
  final List<String> selectedPaths;
  final String? selectedVideoPath;
  final VoidCallback onAdd;
  final VoidCallback onAddVideo;
  final ValueChanged<int> onRemove;
  final VoidCallback onRemoveVideo;
  final VoidCallback onNext;

  const _StepPhotos({
    required this.selectedPaths, this.selectedVideoPath,
    required this.onAdd, required this.onAddVideo,
    required this.onRemove, required this.onRemoveVideo,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _Card(
            icon: Icons.photo_library_outlined, iconBg: AppColors.primary, title: 'صور وفيديو العقار',
            children: [
              // ── زر إضافة صور ──
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.primary.withValues(alpha: 0.6)),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('إضافة صور', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary.withValues(alpha: 0.8))),
                          Text('اختر عدة صور مرة واحدة', style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.5))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── زر إضافة فيديو ──
              GestureDetector(
                onTap: onAddVideo,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: selectedVideoPath != null
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedVideoPath != null
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.15),
                      width: selectedVideoPath != null ? 2 : 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_outlined, size: 32,
                          color: selectedVideoPath != null
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.4)),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedVideoPath != null ? 'تم اختيار الفيديو' : 'إضافة فيديو',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                  color: selectedVideoPath != null ? AppColors.primary : AppColors.primary.withValues(alpha: 0.6))),
                          Text(selectedVideoPath != null ? 'حد أقصى 50 ميجا' : 'اختياري — فيديو واحد فقط',
                              style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.5))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── عرض الصور المختارة ──
              if (selectedPaths.isNotEmpty) ...[
                Row(
                  children: [
                    Text('الصور (${selectedPaths.length})',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedPaths.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(selectedPaths[i]),
                              width: 90, height: 90, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4, left: 4,
                          child: GestureDetector(
                            onTap: () => onRemove(i),
                            child: Container(
                              width: 22, height: 22,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // ── عرض الفيديو المختار ──
              if (selectedVideoPath != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.videocam, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('الفيديو المختار', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                    const Spacer(),
                    GestureDetector(
                      onTap: onRemoveVideo,
                      child: const Text('إزالة', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_outline, color: AppColors.primary, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(selectedVideoPath!.split('/').last,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: AppColors.black)),
                      ),
                    ],
                  ),
                ),
              ],

              // ── رسالة فارغة ──
              if (selectedPaths.isEmpty && selectedVideoPath == null) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(Icons.photo_library_outlined, size: 40, color: AppColors.grey.withValues(alpha: 0.3)),
                        const SizedBox(height: 8),
                        Text('اختر صوراً وفيديو للعقار',
                            style: TextStyle(fontSize: 13, color: AppColors.grey.withValues(alpha: 0.5))),
                        const SizedBox(height: 4),
                        Text('كلها اختياري — يمكنك إضافة الوسائط لاحقاً',
                            style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.4))),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          _NextButton(label: 'التالي: المراجعة', onPressed: onNext),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Step 5: Review + Publish
// ═══════════════════════════════════════════════

class _StepReview extends StatelessWidget {
  final VoidCallback onPublish;
  final bool publishing;
  final String propertyName, propertyType, propertyCity, furnishing;
  final String area, beds, baths, kitchens, guests;
  final String dailyPrice, monthlyPrice, yearlyPrice, period;
  final String address;
  final Set<String> primaryAmenities, secondaryAmenities, kitchenAmenities, bathroomAmenities, propertyFeatures;
  final bool locationPicked;

  const _StepReview({
    required this.onPublish, required this.publishing,
    required this.propertyName, required this.propertyType,
    required this.propertyCity, required this.furnishing,
    required this.area, required this.beds, required this.baths, required this.kitchens, required this.guests,
    required this.dailyPrice, required this.monthlyPrice, required this.yearlyPrice, required this.period,
    required this.address,
    required this.primaryAmenities, required this.secondaryAmenities,
    required this.kitchenAmenities, required this.bathroomAmenities, required this.propertyFeatures,
    required this.locationPicked,
  });

  @override
  Widget build(BuildContext context) {
    final allAmenities = {...primaryAmenities, ...secondaryAmenities, ...kitchenAmenities, ...bathroomAmenities};

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _Card(
            icon: Icons.checklist, iconBg: AppColors.primary, title: 'مراجعة ونشر',
            children: [
              _ReviewRow(label: 'اسم العقار', value: propertyName.isEmpty ? '—' : propertyName),
              _divider, _ReviewRow(label: 'النوع', value: propertyType),
              _divider, _ReviewRow(label: 'المدينة', value: propertyCity),
              _divider, _ReviewRow(label: 'التأثيث', value: furnishing),
              _divider, _ReviewRow(label: 'المساحة', value: area.isEmpty ? '—' : '$area م²'),
              _divider, _ReviewRow(label: 'الغرف/حمامات', value: '$beds غرف / $baths حمام${kitchens.isNotEmpty ? ' / $kitchens مطبخ' : ''}'),
              _divider, _ReviewRow(label: 'الضيوف', value: guests.isEmpty ? '—' : guests),
              _divider, _ReviewRow(label: 'الفترة', value: period),
              _divider, _ReviewRow(label: 'الأسعار', value: _pricesSummary()),
              _divider, _ReviewRow(label: 'الموقع', value: address.isEmpty ? '—' : address),
              _divider, _ReviewRow(label: 'الخريطة', value: locationPicked ? 'تم التحديد ✓' : 'لم يتم التحديد'),
              _divider, _ReviewRow(label: 'المرافق (${allAmenities.length})', value: allAmenities.isEmpty ? '—' : allAmenities.join('، ')),
            ],
          ),
          const SizedBox(height: 24),
          _NextButton(
            label: publishing ? '' : 'نشر العقار',
            onPressed: publishing ? null : onPublish,
            loading: publishing,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  static const _divider = Padding(
    padding: EdgeInsets.symmetric(vertical: 6),
    child: Divider(height: 1, color: AppColors.fieldBorder),
  );

  String _pricesSummary() {
    final parts = <String>[
      if (dailyPrice.isNotEmpty) 'يومي: $dailyPrice',
      if (monthlyPrice.isNotEmpty) 'شهري: $monthlyPrice',
      if (yearlyPrice.isNotEmpty) 'سنوي: $yearlyPrice',
    ];
    return parts.isEmpty ? '—' : parts.join(' • ');
  }
}

// ═══════════════════════════════════════════════
//  Shared Widgets
// ═══════════════════════════════════════════════

class _Card extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final List<Widget> children;

  const _Card({required this.icon, required this.iconBg, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
              child: Icon(icon, color: iconBg == AppColors.fieldBorder ? AppColors.grey : AppColors.white, size: 18)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        ]),
        const SizedBox(height: 20),
        ...children,
      ]),
    );
  }
}

class _FormField extends StatelessWidget {
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  const _FormField({required this.hint, this.maxLines = 1, this.keyboardType, required this.onChanged, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 12 : 4),
      decoration: BoxDecoration(color: AppColors.fieldBg, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        maxLines: maxLines, keyboardType: keyboardType, onChanged: onChanged,
        controller: initialValue != null ? TextEditingController(text: initialValue) : null,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          border: InputBorder.none, hintText: hint, hintTextDirection: TextDirection.rtl,
          hintStyle: TextStyle(fontSize: 14, color: AppColors.grey.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;
  const _InputLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText));
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _DropdownField({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: AppColors.fieldBg, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

class _DropdownColumn extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _DropdownColumn({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _InputLabel(text: label),
      const SizedBox(height: 6),
      _DropdownField(value: value, items: items, onChanged: onChanged),
    ]);
  }
}

class _CountField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  const _CountField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkText)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: AppColors.fieldBg, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(children: [
          GestureDetector(
            onTap: () {
              final n = int.tryParse(value) ?? 0;
              if (n > 0) onChanged('${n - 1}');
            },
            child: Container(width: 28, height: 28,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.fieldBorder)),
                child: const Icon(Icons.remove, size: 16, color: AppColors.grey)),
          ),
          Expanded(child: Center(
            child: value.isEmpty
                ? const Text('—', style: TextStyle(fontSize: 14, color: AppColors.grey))
                : Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          )),
          GestureDetector(
            onTap: () {
              final n = int.tryParse(value) ?? 0;
              onChanged('${n + 1}');
            },
            child: Container(width: 28, height: 28,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.add, size: 16, color: AppColors.primary)),
          ),
        ]),
      ),
    ]);
  }
}

class _PriceField extends StatefulWidget {
  final String label, value;
  final ValueChanged<String> onChanged;
  const _PriceField({required this.label, required this.value, required this.onChanged});

  @override
  State<_PriceField> createState() => _PriceFieldState();
}

class _PriceFieldState extends State<_PriceField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _PriceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _ctrl.text != widget.value) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkText)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: AppColors.fieldBg, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                onChanged: widget.onChanged,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkText),
                decoration: InputDecoration(
                  border: InputBorder.none, hintText: '0', hintTextDirection: TextDirection.rtl,
                  hintStyle: TextStyle(fontSize: 15, color: AppColors.grey.withValues(alpha: 0.4)),
                  isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Text('SAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.grey.withValues(alpha: 0.6))),
          ],
        ),
      ),
    ]);
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
        const Spacer(),
        Flexible(child: Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
            textAlign: TextAlign.left)),
      ]),
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  const _NextButton({required this.label, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4, shadowColor: AppColors.primary.withValues(alpha: 0.3),
        ),
        child: loading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
            : FittedBox(fit: BoxFit.scaleDown,
                child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
