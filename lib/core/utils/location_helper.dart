import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class LocationHelper {
  LocationHelper._();

  /// إحداثيات المدن الشهيرة كـ fallback فوري في حال انقطاع الشبكة أو عدم توفر الإحداثيات
  static final Map<String, LatLng> _cityCoordinates = {
    'الرياض': const LatLng(24.7136, 46.6753),
    'riyadh': const LatLng(24.7136, 46.6753),
    'جدة': const LatLng(21.5433, 39.1728),
    'jeddah': const LatLng(21.5433, 39.1728),
    'الدمام': const LatLng(26.4207, 50.0888),
    'dammam': const LatLng(26.4207, 50.0888),
    'الخبر': const LatLng(26.2172, 50.1971),
    'khobar': const LatLng(26.2172, 50.1971),
    'مكة': const LatLng(21.4225, 39.8262),
    'makkah': const LatLng(21.4225, 39.8262),
    'المدينة': const LatLng(24.5247, 39.5692),
    'madinah': const LatLng(24.5247, 39.5692),
    'أبها': const LatLng(18.2164, 42.5053),
    'abha': const LatLng(18.2164, 42.5053),
    'تبوك': const LatLng(28.3835, 36.5662),
    'tabuk': const LatLng(28.3835, 36.5662),
    'الطائف': const LatLng(21.2854, 40.4222),
    'taif': const LatLng(21.2854, 40.4222),
    'ينبع': const LatLng(24.0891, 38.0637),
    'yanbu': const LatLng(24.0891, 38.0637),
    'القاهرة': const LatLng(30.0444, 31.2357),
    'cairo': const LatLng(30.0444, 31.2357),
    'الإسكندرية': const LatLng(31.2001, 29.9187),
    'alexandria': const LatLng(31.2001, 29.9187),
    'الجيزة': const LatLng(30.0131, 31.2089),
    'giza': const LatLng(30.0131, 31.2089),
    'دبي': const LatLng(25.2048, 55.2708),
    'dubai': const LatLng(25.2048, 55.2708),
    'أبوظبي': const LatLng(24.4539, 54.3773),
    'abu dhabi': const LatLng(24.4539, 54.3773),
    'الدوحة': const LatLng(25.2854, 51.5310),
    'doha': const LatLng(25.2854, 51.5310),
    'الكويت': const LatLng(29.3759, 47.9774),
    'kuwait': const LatLng(29.3759, 47.9774),
    'عمان': const LatLng(31.9454, 35.9284),
    'amman': const LatLng(31.9454, 35.9284),
  };

  /// يرجع إحداثيات افتراضية للمدينة أو العنوان إن وُجد تطابق
  static LatLng? getFallbackCoords(String? locationOrCity) {
    if (locationOrCity == null || locationOrCity.trim().isEmpty) {
      return _cityCoordinates['الرياض'];
    }
    final clean = locationOrCity.trim().toLowerCase();
    for (final entry in _cityCoordinates.entries) {
      if (clean.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return const LatLng(24.7136, 46.6753); // الرياض كافتراضي
  }

  /// Geocoding: تحويل العنوان لنص إلى إحداثيات LatLng
  static Future<LatLng?> geocodeAddress(String query) async {
    final q = query.trim();
    if (q.isEmpty) return null;
    try {
      final dio = Dio();
      final res = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {'q': q, 'format': 'json', 'limit': 1},
        options: Options(
          headers: {'User-Agent': 'KeyDarApp/1.0 (contact@keydar.app)'},
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final data = res.data;
      if (data is List && data.isNotEmpty) {
        final lat = double.tryParse('${data[0]['lat']}');
        final lon = double.tryParse('${data[0]['lon']}');
        if (lat != null && lon != null) {
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      debugPrint('Geocode error: $e');
    }
    return getFallbackCoords(q);
  }

  /// Reverse Geocoding: تحويل الإحداثيات إلى اسم العنوان/الحي
  static Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final dio = Dio();
      final res = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {'lat': lat, 'lon': lng, 'format': 'json', 'addressdetails': 1},
        options: Options(
          headers: {'User-Agent': 'KeyDarApp/1.0 (contact@keydar.app)'},
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final data = res.data;
      if (data is Map) {
        final displayName = data['display_name'] as String?;
        final addr = data['address'];
        if (addr is Map) {
          final road = addr['road'] ?? addr['suburb'] ?? addr['neighbourhood'] ?? '';
          final city = addr['city'] ?? addr['town'] ?? addr['state'] ?? '';
          if (road.toString().isNotEmpty && city.toString().isNotEmpty) {
            return '$road, $city';
          }
        }
        return displayName;
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
    return null;
  }
}
