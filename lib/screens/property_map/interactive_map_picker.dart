import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/location_helper.dart';

class MapLocationResult {
  final LatLng coordinates;
  final String? address;

  const MapLocationResult({
    required this.coordinates,
    this.address,
  });
}

class InteractiveMapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;

  const InteractiveMapPickerScreen({
    super.key,
    this.initialLocation,
    this.initialAddress,
  });

  @override
  State<InteractiveMapPickerScreen> createState() => _InteractiveMapPickerScreenState();
}

class _InteractiveMapPickerScreenState extends State<InteractiveMapPickerScreen> {
  late WebViewController _webController;
  late LatLng _currentLocation;
  String _currentAddress = '';
  bool _isLoading = true;
  bool _isLocating = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation ??
        LocationHelper.getFallbackCoords(widget.initialAddress) ??
        const LatLng(24.7136, 46.6753);
    _currentAddress = widget.initialAddress ?? '';

    _initWebView();
    if (_currentAddress.isEmpty) {
      _fetchAddressForCoords(_currentLocation);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initWebView() {
    final lat = _currentLocation.latitude;
    final lng = _currentLocation.longitude;

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        body, html, #map {
            margin: 0; padding: 0; height: 100%; width: 100%;
        }
    </style>
</head>
<body>
    <div id="map"></div>
    <script>
        var map = L.map('map', {
            center: [$lat, $lng],
            zoom: 16,
            zoomControl: true
        });

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '© OpenStreetMap'
        }).addTo(map);

        var marker = L.marker([$lat, $lng], {
            draggable: true
        }).addTo(map);

        function updatePosition(lat, lng) {
            marker.setLatLng([lat, lng]);
            if (window.FlutterLocation) {
                window.FlutterLocation.postMessage(JSON.stringify({lat: lat, lng: lng}));
            }
        }

        marker.on('dragend', function(e) {
            var pos = marker.getLatLng();
            updatePosition(pos.lat, pos.lng);
        });

        map.on('click', function(e) {
            updatePosition(e.latlng.lat, e.latlng.lng);
        });

        window.flyToLocation = function(lat, lng) {
            map.flyTo([lat, lng], 16);
            marker.setLatLng([lat, lng]);
            updatePosition(lat, lng);
        };
    </script>
</body>
</html>
''';

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterLocation',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            final lat = (data['lat'] as num).toDouble();
            final lng = (data['lng'] as num).toDouble();
            setState(() {
              _currentLocation = LatLng(lat, lng);
            });
            _fetchAddressForCoords(_currentLocation);
          } catch (e) {
            debugPrint('Error parsing js message: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(htmlContent);
  }

  Future<void> _fetchAddressForCoords(LatLng pos) async {
    final addr = await LocationHelper.reverseGeocode(pos.latitude, pos.longitude);
    if (addr != null && addr.isNotEmpty && mounted) {
      setState(() {
        _currentAddress = addr;
      });
    }
  }

  Future<void> _searchAndFly(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final coords = await LocationHelper.geocodeAddress(query);
    setState(() => _isLoading = false);

    if (coords != null) {
      setState(() {
        _currentLocation = coords;
        _currentAddress = query;
      });
      _webController.runJavaScript('window.flyToLocation(${coords.latitude}, ${coords.longitude});');
    } else {
      Get.snackbar('لم يتم العثور', 'جرب البحث باسم حي أو شارع أوضح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF8F00),
          colorText: Colors.white);
    }
  }

  Future<void> _locateUserGPS() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('خدمة الموقع مغلقة', 'يرجى تفعيل خدمة الـ GPS على هاتفك',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFC62828),
            colorText: Colors.white);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('الصلاحية مطلوبة', 'يرجى السماح للتطبيق بالوصول للموقع',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE65100),
              colorText: Colors.white);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('الصلاحية مرفوضة نهائياً', 'افتح إعدادات الهاتف وفعّل إذن الموقع',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFC62828),
            colorText: Colors.white);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final newPos = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = newPos;
      });
      _webController.runJavaScript('window.flyToLocation(${newPos.latitude}, ${newPos.longitude});');
      _fetchAddressForCoords(newPos);
    } catch (e) {
      Get.snackbar('خطأ', 'تعذر جلب موقعك الحالي',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFC62828),
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _confirmAndReturn() {
    final result = MapLocationResult(
      coordinates: _currentLocation,
      address: _currentAddress.isNotEmpty ? _currentAddress : null,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.darkText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('تحديد موقع العقار على الخريطة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── الخريطة التفاعلية ──
          WebViewWidget(controller: _webController),

          if (_isLoading)
            const Center(
              child: Card(
                elevation: 4,
                shape: CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                ),
              ),
            ),

          // ── شريط البحث بالأعلى ──
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                textInputAction: TextInputAction.search,
                onSubmitted: _searchAndFly,
                decoration: InputDecoration(
                  hintText: 'ابحث باسم المدينة أو الحي أو الشارع...',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.grey.withValues(alpha: 0.7)),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search, color: AppColors.primary),
                    onPressed: () => _searchAndFly(_searchController.text),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: AppColors.grey, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // ── زر موقعي الحالي (GPS) ──
          Positioned(
            bottom: 180,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'my_gps_location_btn',
              backgroundColor: Colors.white,
              onPressed: _locateUserGPS,
              child: _isLocating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

          // ── بطاقة تأكيد الموقع بالأسفل ──
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentAddress.isNotEmpty
                                  ? _currentAddress
                                  : 'الموقع المحدد على الخريطة',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_currentLocation.latitude.toStringAsFixed(5)}, ${_currentLocation.longitude.toStringAsFixed(5)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.grey.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _confirmAndReturn,
                    icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.white),
                    label: const Text(
                      'تأكيد واختيار هذا الموقع',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
