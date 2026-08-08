import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../models/property.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  int _currentStep = 0;
  late PageController _pageController;

  // Step 1
  String _propertyName = '';
  String _propertyDescription = '';
  String _propertyType = 'فيلا';
  String _propertyCity = 'الرياض';
  String _monthlyPrice = '';

  // Step 2
  String _address = '';

  // Step 3
  bool _hasMainImage = false;
  final List<bool> _extraImages = [false, false, false, false];

  // Step 4
  final Set<String> _selectedAmenities = {};

  // Step 5
  late int _currentMonth;
  late int _currentYear;
  final Set<int> _bookedDays = {15, 16, 17};
  final Set<int> _availableDays = {1, 2, 3, 5, 8, 10, 12, 20, 22, 25, 28, 29, 30};
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final now = DateTime.now();
    _currentMonth = now.month;
    _currentYear = now.year;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < 5) {
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

  void _publish() {
    final ctrl = Get.find<AppController>();
    ctrl.ownerProperties.add(Property(
      title: _propertyName.isEmpty ? 'عقار جديد' : _propertyName,
      type: _propertyType,
      location: '$_propertyCity${_address.isNotEmpty ? "، $_address" : ""}',
      price: _monthlyPrice.isEmpty ? '0' : _monthlyPrice,
      period: 'شهري',
      rating: 4.5,
      reviews: 0,
      bedrooms: 4,
      bathrooms: 2,
      area: 120,
      image: 'assets/image/building.jpg',
      description: _propertyDescription.isEmpty ? 'وصف العقار' : _propertyDescription,
      badge1: 'نشط',
      amenities: _selectedAmenities.toList(),
    ));
    Get.back();
  }

  String get _selectedAmenitiesStr {
    if (_selectedAmenities.isEmpty) return 'لم يتم الاختيار';
    return _selectedAmenities.join('، ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fieldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('إضافة عقار جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        leading: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: _back,
          ),
        ),
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
                    value: (_currentStep + 1) / 6,
                    backgroundColor: AppColors.fieldBorder,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text('الخطوة ${_currentStep + 1} من 6', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
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
                  step: 1, onNext: _next,
                  propertyName: _propertyName,
                  propertyDescription: _propertyDescription,
                  propertyType: _propertyType,
                  propertyCity: _propertyCity,
                  monthlyPrice: _monthlyPrice,
                  onNameChanged: (v) => setState(() => _propertyName = v),
                  onDescriptionChanged: (v) => setState(() => _propertyDescription = v),
                  onTypeChanged: (v) => setState(() => _propertyType = v),
                  onCityChanged: (v) => setState(() => _propertyCity = v),
                  onPriceChanged: (v) => setState(() => _monthlyPrice = v),
                ),
                _StepLocation(
                  step: 2, onNext: _next,
                  address: _address,
                  onAddressChanged: (v) => setState(() => _address = v),
                ),
                _StepPhotos(
                  step: 3, onNext: _next,
                  hasMainImage: _hasMainImage,
                  extraImages: _extraImages,
                  onAddMain: () => setState(() => _hasMainImage = true),
                  onAddExtra: (i) => setState(() => _extraImages[i] = true),
                ),
                _StepAmenities(
                  step: 4, onNext: _next,
                  selectedAmenities: _selectedAmenities,
                  onToggle: (label) => setState(() {
                    if (_selectedAmenities.contains(label)) {
                      _selectedAmenities.remove(label);
                    } else {
                      _selectedAmenities.add(label);
                    }
                  }),
                ),
                _StepAvailability(
                  step: 5, onNext: _next,
                  currentMonth: _currentMonth,
                  currentYear: _currentYear,
                  bookedDays: _bookedDays,
                  availableDays: _availableDays,
                  selectedDay: _selectedDay,
                  onPrevMonth: () => setState(() {
                    if (_currentMonth == 1) {
                      _currentMonth = 12;
                      _currentYear--;
                    } else {
                      _currentMonth--;
                    }
                  }),
                  onNextMonth: () => setState(() {
                    if (_currentMonth == 12) {
                      _currentMonth = 1;
                      _currentYear++;
                    } else {
                      _currentMonth++;
                    }
                  }),
                  onDayTap: (day) => setState(() {
                    if (day == _selectedDay) {
                      _selectedDay = null;
                    } else {
                      _selectedDay = day;
                    }
                  }),
                ),
                _StepReview(
                  step: 6, onPublish: _publish,
                  propertyName: _propertyName,
                  propertyType: _propertyType,
                  propertyCity: _propertyCity,
                  monthlyPrice: _monthlyPrice,
                  address: _address,
                  amenities: _selectedAmenitiesStr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───── Step 1: Property Info ─────
class _StepInfo extends StatelessWidget {
  final int step;
  final VoidCallback onNext;
  final String propertyName, propertyDescription, propertyType, propertyCity, monthlyPrice;
  final ValueChanged<String> onNameChanged, onDescriptionChanged, onTypeChanged, onCityChanged, onPriceChanged;
  const _StepInfo({
    required this.step, required this.onNext,
    required this.propertyName, required this.propertyDescription,
    required this.propertyType, required this.propertyCity, required this.monthlyPrice,
    required this.onNameChanged, required this.onDescriptionChanged,
    required this.onTypeChanged, required this.onCityChanged, required this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.fieldBorder),
                      child: const Icon(Icons.help_outline, color: AppColors.grey, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('معلومات العقار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                  ],
                ),
                const SizedBox(height: 20),
                const _InputLabel(text: 'اسم العقار'),
                const SizedBox(height: 6),
                _FormField(hint: 'مثال: فيلا فاخرة بموقع مميز', onChanged: onNameChanged),
                const SizedBox(height: 16),
                const _InputLabel(text: 'وصف العقار'),
                const SizedBox(height: 6),
                _FormField(hint: 'اكتب وصفاً مفصلاً للعقار...', maxLines: 4, onChanged: onDescriptionChanged),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _InputLabel(text: 'نوع العقار'),
                        const SizedBox(height: 6),
                        _DropdownField(
                          value: propertyType,
                          items: const ['فيلا', 'شقة', 'مكتب', 'دوبلكس', 'استوديو', 'بنتهاوس', 'تجاري', 'مزرعة'],
                          onChanged: onTypeChanged,
                        ),
                      ],
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _InputLabel(text: 'المدينة'),
                        const SizedBox(height: 6),
                        _DropdownField(
                          value: propertyCity,
                          items: const ['الرياض', 'جدة', 'الدمام', 'الخبر', 'مكة', 'المدينة', 'أبها', 'تبوك'],
                          onChanged: onCityChanged,
                        ),
                      ],
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                const _InputLabel(text: 'السعر الشهري (SAR)'),
                const SizedBox(height: 6),
                _FormField(hint: '3,200', keyboardType: TextInputType.number, onChanged: onPriceChanged),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _NextButton(step: step, onPressed: onNext),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ───── Step 2: Location ─────
class _StepLocation extends StatelessWidget {
  final int step;
  final VoidCallback onNext;
  final String address;
  final ValueChanged<String> onAddressChanged;
  const _StepLocation({
    required this.step, required this.onNext,
    required this.address, required this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                      child: const Icon(Icons.location_on, color: AppColors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('الموقع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map, color: AppColors.white, size: 48),
                        SizedBox(height: 8),
                        Text('الخريطة', style: TextStyle(color: AppColors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('حي الياسمين، الرياض، المملكة العربية السعودية',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormField(hint: 'أدخل عنوان العقار التفصيلي...', onChanged: onAddressChanged),
          const SizedBox(height: 24),
          _NextButton(step: step, onPressed: onNext),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ───── Step 3: Photos ─────
class _StepPhotos extends StatelessWidget {
  final int step;
  final VoidCallback onNext;
  final bool hasMainImage;
  final List<bool> extraImages;
  final VoidCallback onAddMain;
  final ValueChanged<int> onAddExtra;
  const _StepPhotos({
    required this.step, required this.onNext,
    required this.hasMainImage, required this.extraImages,
    required this.onAddMain, required this.onAddExtra,
  });

  void _showPicker(BuildContext context, VoidCallback onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.fieldBorder, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('اختيار صورة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('الكاميرا', style: TextStyle(fontSize: 14)),
              onTap: () { Navigator.pop(context); onSelect(); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('المعرض', style: TextStyle(fontSize: 14)),
              onTap: () { Navigator.pop(context); onSelect(); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.image, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('الصور', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _showPicker(context, onAddMain),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: hasMainImage ? AppColors.primary.withValues(alpha: 0.1) : AppColors.fieldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasMainImage ? AppColors.primary : AppColors.fieldBorder,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: hasMainImage
                          ? const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: AppColors.primary, size: 40),
                                SizedBox(height: 8),
                                Text('تم إضافة الصورة الرئيسية', style: TextStyle(fontSize: 14, color: AppColors.primary)),
                              ],
                            )
                          : const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt, color: AppColors.grey, size: 40),
                                SizedBox(height: 8),
                                Text('أضف صورة رئيسية', style: TextStyle(fontSize: 14, color: AppColors.grey)),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(4, (i) => GestureDetector(
                      onTap: extraImages[i] ? null : () => _showPicker(context, () => onAddExtra(i)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: extraImages[i] ? AppColors.primary.withValues(alpha: 0.1) : AppColors.fieldBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: extraImages[i] ? AppColors.primary : AppColors.fieldBorder,
                              width: 1.5,
                            ),
                          ),
                          child: extraImages[i]
                              ? const Icon(Icons.check_circle, color: AppColors.primary, size: 28)
                              : const Icon(Icons.add, color: AppColors.grey, size: 28),
                        ),
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _NextButton(step: step, onPressed: onNext),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ───── Step 4: Amenities ─────
class _StepAmenities extends StatelessWidget {
  final int step;
  final VoidCallback onNext;
  final Set<String> selectedAmenities;
  final ValueChanged<String> onToggle;
  const _StepAmenities({
    required this.step, required this.onNext,
    required this.selectedAmenities, required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.grid_view, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('المرافق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: (const [
                    {'icon': Icons.wifi, 'label': 'إنترنت'},
                    {'icon': Icons.fitness_center, 'label': 'نادي رياضي'},
                    {'icon': Icons.pool, 'label': 'مسبح'},
                    {'icon': Icons.local_parking, 'label': 'موقف'},
                    {'icon': Icons.security, 'label': 'أمن 24/7'},
                    {'icon': Icons.elevator, 'label': 'مصعد'},
                  ]).map((a) {
                    final label = a['label'] as String;
                    final isSelected = selectedAmenities.contains(label);
                    return _AmenityChip(
                      icon: a['icon'] as IconData,
                      label: label,
                      isSelected: isSelected,
                      onTap: () => onToggle(label),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _NextButton(step: step, onPressed: onNext),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _AmenityChip({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.fieldBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primary : AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, color: isSelected ? AppColors.primary : AppColors.grey)),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ───── Step 5: Calendar ─────
class _StepAvailability extends StatelessWidget {
  final int step;
  final VoidCallback onNext;
  final int currentMonth, currentYear;
  final Set<int> bookedDays, availableDays;
  final int? selectedDay;
  final VoidCallback onPrevMonth, onNextMonth;
  final ValueChanged<int> onDayTap;
  const _StepAvailability({
    required this.step, required this.onNext,
    required this.currentMonth, required this.currentYear,
    required this.bookedDays, required this.availableDays,
    required this.selectedDay, required this.onPrevMonth,
    required this.onNextMonth, required this.onDayTap,
  });

  static const _monthNames = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String get _monthLabel => '${_monthNames[currentMonth - 1]} $currentYear';

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    final firstWeekday = DateTime(currentYear, currentMonth, 1).weekday;
    final offset = (firstWeekday + 1) % 7;
    final weeksNeeded = ((daysInMonth + offset - 1) / 7).ceil();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.fieldBorder),
                      child: const Icon(Icons.calendar_today, color: AppColors.grey, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('التقويم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(onTap: onPrevMonth, child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.chevron_right, color: AppColors.primary, size: 28),
                          )),
                          const Spacer(),
                          Text(_monthLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
                          const Spacer(),
                          GestureDetector(onTap: onNextMonth, child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.chevron_left, color: AppColors.primary, size: 28),
                          )),
                        ],
                      ),
                      const Divider(height: 1, color: AppColors.fieldBorder),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'].map((d) =>
                            Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.grey))))
                          ).toList(),
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.fieldBorder),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: List.generate(weeksNeeded, (w) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: List.generate(7, (d) {
                                final day = w * 7 + d - offset + 1;
                                if (day < 1 || day > daysInMonth) return const Expanded(child: SizedBox(height: 40));
                                final isBooked = bookedDays.contains(day);
                                final isAvailable = availableDays.contains(day);
                                final isSelected = day == selectedDay;
                                Color bg;
                                Color textColor;
                                if (isSelected) {
                                  bg = AppColors.primary;
                                  textColor = AppColors.white;
                                } else if (isBooked) {
                                  bg = const Color(0xFFFFCDD2);
                                  textColor = const Color(0xFFC62828);
                                } else if (isAvailable) {
                                  bg = const Color(0xFFC8E6C9);
                                  textColor = const Color(0xFF2E7D32);
                                } else {
                                  bg = Colors.transparent;
                                  textColor = AppColors.darkText;
                                }
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => onDayTap(day),
                                    child: Container(
                                      height: 40,
                                      margin: const EdgeInsets.symmetric(horizontal: 1),
                                      decoration: BoxDecoration(
                                        color: bg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('$day', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2E7D32))),
                        const SizedBox(width: 6),
                        const Text('متاح', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFC62828))),
                        const SizedBox(width: 6),
                        const Text('محجوز', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary)),
                        const SizedBox(width: 6),
                        const Text('محدد', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                      ],
                    ),
                  ],
                ),
                if (selectedDay != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text(
                      '${_monthNames[currentMonth - 1]} $selectedDay — ${bookedDays.contains(selectedDay!) ? 'محجوز' : availableDays.contains(selectedDay!) ? 'متاح' : 'غير محدد'}',
                      style: const TextStyle(fontSize: 14, color: AppColors.white, fontWeight: FontWeight.bold),
                    )),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _NextButton(step: step, onPressed: onNext),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ───── Step 6: Review ─────
class _StepReview extends StatelessWidget {
  final int step;
  final VoidCallback onPublish;
  final String propertyName, propertyType, propertyCity, monthlyPrice, address, amenities;
  const _StepReview({
    required this.step, required this.onPublish,
    required this.propertyName, required this.propertyType,
    required this.propertyCity, required this.monthlyPrice,
    required this.address, required this.amenities,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.checklist, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('مراجعة ونشر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                  ],
                ),
                const SizedBox(height: 20),
                _ReviewRow(label: 'اسم العقار', value: propertyName.isEmpty ? 'لم يتم الإدخال' : propertyName),
                const Divider(height: 20, color: AppColors.fieldBorder),
                _ReviewRow(label: 'نوع العقار', value: propertyType),
                const Divider(height: 20, color: AppColors.fieldBorder),
                _ReviewRow(label: 'المدينة', value: propertyCity),
                const Divider(height: 20, color: AppColors.fieldBorder),
                _ReviewRow(label: 'السعر', value: monthlyPrice.isEmpty ? 'لم يتم الإدخال' : '$monthlyPrice ر.س / شهرياً'),
                const Divider(height: 20, color: AppColors.fieldBorder),
                _ReviewRow(label: 'الموقع', value: address.isEmpty ? 'لم يتم الإدخال' : address),
                const Divider(height: 20, color: AppColors.fieldBorder),
                _ReviewRow(label: 'المرافق', value: amenities),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _NextButton(step: step, onPressed: onPublish),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
        const Spacer(),
        Flexible(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText), textAlign: TextAlign.left)),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  final int step;
  final VoidCallback onPressed;
  const _NextButton({required this.step, required this.onPressed});

  String get _label {
    const labels = ['الموقع', 'الصور', 'المرافق', 'التقويم', 'المراجعة'];
    if (step == 6) return 'نشر العقار';
    if (step >= 1 && step <= 5) return 'التالي: ${labels[step - 1]}';
    return 'التالي';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
        ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(_label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
      ),
    );
  }
}

// ───── Shared widgets ─────
class _InputLabel extends StatelessWidget {
  final String text;
  const _InputLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText));
  }
}

class _FormField extends StatelessWidget {
  final String hint;
  final int? maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  const _FormField({required this.hint, this.maxLines, this.keyboardType, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: TextField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.grey),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _DropdownField({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.fieldBorder, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 12),
                    ...items.map((item) => ListTile(
                      title: Text(item, style: TextStyle(fontSize: 14, color: item == value ? AppColors.primary : AppColors.darkText)),
                      trailing: item == value ? const Icon(Icons.check, color: AppColors.primary, size: 20) : null,
                      onTap: () { Navigator.pop(context); onChanged(item); },
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Row(
          children: [
            Text(value, style: const TextStyle(fontSize: 14, color: AppColors.darkText)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
