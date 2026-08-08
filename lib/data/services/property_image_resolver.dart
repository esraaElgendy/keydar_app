import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../models/property.dart';
import '../repositories/property_repository.dart';

/// ضمان عرض صورة العقار في الحجوزات، لأن الـ API لا يرسل صورة العقار داخل
/// كائن الحجز (يقوم بإرجاع `image: null` في `booking.property.image`).
///
/// الترتيب: كاش محلي طبق القوائم المحمّلة في [AppController] طبق جلب تفاصيل
/// العقار (مرة واحدة فقط لكل عقار).
class PropertyImageResolver {
  PropertyImageResolver._();

  static final Map<int, String> _cache = {};

  /// يُرجع صورة جاهزة (من الكاش أو القوائم المحمّلة) دون أي طلب شبكة.
  static String? find(int? propertyId) {
    if (propertyId == null) return null;
    final cached = _cache[propertyId];
    if (cached != null) return cached;
    return _findInLoadedLists(propertyId);
  }

  /// يُرجع صورة مؤكدة: كاش → قوائم التطبيق → تفاصيل العقار (شبكة).
  static Future<String?> resolve(int? propertyId) async {
    final existing = find(propertyId);
    if (existing != null && existing.isNotEmpty) return existing;
    if (propertyId == null) return null;
    try {
      final detail = await PropertyRepository().fetchDetail(id: propertyId);
      final url = detail.imageUrl;
      if (url != null && url.isNotEmpty) {
        _cache[propertyId] = url;
        return url;
      }
    } catch (_) {
      // صامت: نعود إلى الـ fallback.
    }
    return null;
  }

  static String? _findInLoadedLists(int propertyId) {
    Property? found;
    try {
      final app = Get.find<AppController>();
      for (final p in app.allProperties) {
        if (p.id == propertyId) {
          found = p;
          break;
        }
      }
      if (found == null) {
        for (final p in app.latestProperties) {
          if (p.id == propertyId) {
            found = p;
            break;
          }
        }
      }
    } catch (_) {
      // AppController غير محمّل بعد.
    }
    final url = found?.imageUrl;
    if (url != null && url.isNotEmpty) {
      _cache[propertyId] = url;
      return url;
    }
    return null;
  }
}