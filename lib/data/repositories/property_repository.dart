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
}