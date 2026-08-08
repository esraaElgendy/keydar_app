import '../../core/constants/app_config.dart';
import '../../models/property.dart';
import '../models/api_property.dart';
import '../models/review.dart';
import '../services/api_client.dart';

/// طبقة الوصول لعقارات الـ API.
class PropertyRepository {
  final ApiClient _api = ApiClient.instance;

  /// أحدث العقارات للعرض على الصفحة الرئيسية.
  /// [limit] عدد النتائج المطلوبة من السيرفر.
  Future<List<Property>> fetchLatest({int limit = 6}) async {
    final res = await _api.get(
      AppConfig.latestProperties,
      query: {'limit': limit},
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      return const [];
    }
    return ApiPropertiesResponse.fromJson(data).toProperties();
  }

  /// جميع العقارات المتاحة.
  Future<List<Property>> fetchAll() async {
    final res = await _api.get(AppConfig.allProperties);
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      return const [];
    }
    return ApiPropertiesResponse.fromJson(data).toProperties();
  }

  /// تفاصيل عقار واحد كاملة.
  Future<Property> fetchDetail({required int id}) async {
    final res = await _api.get(AppConfig.propertyDetail(id));
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    return ApiPropertyDetailResponse.fromJson(data).toProperty();
  }

  /// تقييمات عقار مع الترقيم (صفحة واحدة).
  Future<ReviewsPage> fetchReviews({
    required int propertyId,
    int page = 1,
    int limit = 6,
  }) async {
    final res = await _api.get(
      AppConfig.propertyReviews(propertyId),
      query: {'page': page, 'limit': limit},
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    return ReviewsPage.fromJson(data);
  }

  /// إضافة تقييم لعقار (يتطلب تسجيل دخول).
  /// [title] عنوان اختياري للتقييم، و [wouldRecommend] هل يوصي المستخدم بالعقار.
  Future<void> addReview({
    required int propertyId,
    required int rating,
    required String text,
    String? title,
    bool wouldRecommend = false,
  }) async {
    await _api.post(
      AppConfig.propertyReviews(propertyId),
      body: {
        'rating': rating,
        'text': text,
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
        'wouldRecommend': wouldRecommend,
      },
    );
  }

  /// تمييز تقييم كمفيد (يتطلب تسجيل دخول).
  /// يرجع عدد "مفيد" الجديد بعد التمييز.
  Future<int> markReviewHelpful({
    required int propertyId,
    required int reviewId,
  }) async {
    final res = await _api.post(
      AppConfig.propertyReviewHelpful(propertyId, reviewId),
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return (data['helpful'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  // ===== Favorites =====

  /// قائمة العقارات المفضلة للمستأجر (يتطلب تسجيل دخول).
  Future<List<Property>> fetchFavorites({int limit = 50}) async {
    final res = await _api.get(
      AppConfig.customerFavorites,
      query: {'limit': limit},
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      return const [];
    }
    final raw = data['favorites'];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((e) {
      final j = Map<String, dynamic>.from(e);
      final rawArea = j['area'];
      return Property(
        id: (j['id'] as num?)?.toInt(),
        title: j['title'] as String? ?? '',
        type: j['type'] as String? ?? 'عقار',
        location: j['location'] as String? ?? '',
        price: _fmtNumber(j['price']),
        period: j['period'] as String? ?? '',
        rating: (j['rating'] as num?)?.toDouble() ?? 0,
        reviews: 0,
        bedrooms: (j['bedrooms'] as num?)?.toInt() ?? 0,
        bathrooms: (j['bathrooms'] as num?)?.toInt() ?? 0,
        area: _toDouble(rawArea) ?? 0,
        image: '',
        description: '',
        badge1: j['status'] as String? ?? 'متاح',
        isFavorite: true,
        imageUrl: AppConfig.assetUrl(j['image'] as String?),
        status: j['status'] as String?,
      );
    }).toList();
  }

  /// إضافة عقار إلى المفضلة (يتطلب تسجيل دخول).
  Future<bool> addFavorite({required int propertyId}) async {
    final res = await _api.post(AppConfig.customerFavorite(propertyId));
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return data['isFavorite'] == true;
    }
    return true;
  }

  /// إزالة عقار من المفضلة (يتطلب تسجيل دخول).
  Future<bool> removeFavorite({required int propertyId}) async {
    final res = await _api.delete(AppConfig.customerFavorite(propertyId));
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return data['isFavorite'] != true;
    }
    return true;
  }

  /// حالة تفضيل عقار — هل هو في المفضلة؟ (يتطلب تسجيل دخول).
  Future<bool> fetchFavoriteStatus({required int propertyId}) async {
    final res = await _api.get(AppConfig.customerFavoriteStatus(propertyId));
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return data['isFavorite'] == true;
    }
    return false;
  }

  static String _fmtNumber(dynamic v) {
    final n = _toDouble(v);
    if (n == null) return '0';
    final s = n.toInt().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final remaining = s.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }

  static double? _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', ''));
    return null;
  }
}