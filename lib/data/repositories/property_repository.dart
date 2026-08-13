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
  /// [limit] عدد العناصر المطلوبة — الافتراضي بالسيرفر 10 فقط،
  /// لذلك نطلبه أكبر لضمان ظهور كل العقارات المنشورة حديثاً.
  Future<List<Property>> fetchAll({int limit = 100}) async {
    final res = await _api.get(
      AppConfig.allProperties,
      query: {'limit': limit},
    );
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

  // ===== Owner - Create Property =====

  /// إضافة عقار جديد بواسطة المالك (يتطلب تسجيل دخول المالك).
  /// يرجع العقار المُنشأ كما أعاده السيرفر (بعد قبول المراجعة يكون pending).
  Future<Property> createOwnerProperty({
    required String title,
    required String description,
    required String location,
    required String city,
    required String propertyType,
    required String furnishing,
    required num area,
    required Map<String, num> prices,
    required String period,
    required String status,
    required int beds,
    required int baths,
    required int kitchens,
    required int guests,
    String? floor,
    String? buildingNumber,
    List<String> amenities = const [],
    List<String> primaryAmenities = const [],
    List<String> secondaryAmenities = const [],
    List<String> kitchenAmenities = const [],
    List<String> bathroomAmenities = const [],
    List<String> propertyFeatures = const [],
    String cancellationPolicy = 'Flexible',
  }) async {
    final res = await _api.post(
      AppConfig.ownerProperties,
      body: {
        'title': title,
        'description': description,
        'location': location,
        'city': city,
        'property_type': propertyType,
        'furnishing': furnishing,
        'area': area,
        'prices': prices,
        'period': period,
        'status': status,
        'beds': beds,
        'baths': baths,
        'kitchens': kitchens,
        'guests': guests,
        if (floor != null && floor.isNotEmpty) 'floor': floor,
        if (buildingNumber != null && buildingNumber.isNotEmpty)
          'building_number': buildingNumber,
        'amenities': amenities,
        'primary_amenities': primaryAmenities,
        'secondary_amenities': secondaryAmenities,
        'kitchen_amenities': kitchenAmenities,
        'bathroom_amenities': bathroomAmenities,
        'property_features': propertyFeatures,
        'cancellation_policy': cancellationPolicy,
      },
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    return ApiPropertyDetailResponse.fromJson(data).toProperty();
  }

  // ===== Owner - My Properties =====

  /// قائمة عقارات المالك الحالية من السيرفر (يتطلب تسجيل دخول المالك).
  Future<List<Property>> fetchOwnerMyProperties({int page = 1, int limit = 50}) async {
    final res = await _api.get(
      AppConfig.ownerMyProperties,
      query: {'page': page, 'limit': limit},
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      return const [];
    }
    final raw = data['properties'];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((e) {
      final j = Map<String, dynamic>.from(e);
      return ApiPropertyDetailResponse.fromJson({'property': j}).toProperty();
    }).toList();
  }

  /// تفاصيل عقار مالك واحد من السيرفر — يُستخدم لفتح صفحة التفاصيل (GET).
  Future<Property> fetchOwnerPropertyDetail({required int id}) async {
    final res = await _api.get(AppConfig.ownerPropertyDetail(id));
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    return ApiPropertyDetailResponse.fromJson(data).toProperty();
  }

  /// تغيير حالة عقار المالك (PUT `/owner/properties/{id}/status`).
  /// [status] قيمة الـ Backend: `available` / `rented`.
  /// يرجع العقار المحدَّث كما أعاده السيرفر.
  Future<Property> updateOwnerPropertyStatus({
    required int id,
    required String status,
  }) async {
    final res = await _api.put(
      AppConfig.ownerPropertyStatus(id),
      body: {'status': status},
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    return ApiPropertyDetailResponse.fromJson(data).toProperty();
  }

  /// تعديل عقار مالك — PUT كامل، لذلك يُرسل كل الحقول كما هي في الـ Backend.
  /// يحافظ على القيم الحالية (من [current]) لأي حقل غير معدَّل.
  Future<Property> updateOwnerProperty({
    required int id,
    required Property current,
    int? beds,
    int? baths,
    int? guests,
    num? area,
    String? title,
    String? description,
    String? location,
    String? city,
    String? propertyType,
    String? furnishing,
    String? period,
    Map<String, num>? prices,
    List<String>? amenities,
    List<String>? primaryAmenities,
    List<String>? secondaryAmenities,
    List<String>? kitchenAmenities,
    List<String>? bathroomAmenities,
    List<String>? propertyFeatures,
  }) async {
    final res = await _api.put(
      AppConfig.ownerPropertyDetail(id),
      body: {
        'title': title ?? current.title,
        'description': description ?? current.description,
        'location': location ?? current.location,
        'city': city ?? current.city ?? 'Riyadh',
        'property_type': propertyType ?? current.type,
        'furnishing': furnishing ?? current.furnishing ?? 'furnished',
        'area': area ?? current.area,
        'prices': prices ?? current.prices ?? {},
        'period': _toPeriodKey(period ?? current.period),
        'status': 'available',
        'beds': beds ?? current.bedrooms,
        'baths': baths ?? current.bathrooms,
        'kitchens': 0,
        'guests': guests ?? current.guests,
        'floor': current.floor,
        'amenities': amenities ?? current.amenities,
        'primary_amenities': primaryAmenities ?? current.primaryAmenities,
        'secondary_amenities': secondaryAmenities ?? current.secondaryAmenities,
        'kitchen_amenities': kitchenAmenities ?? current.kitchenAmenities,
        'bathroom_amenities': bathroomAmenities ?? current.bathroomAmenities,
        'property_features': propertyFeatures ?? current.features,
        'cancellation_policy': 'Flexible',
      },
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    return ApiPropertyDetailResponse.fromJson(data).toProperty();
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

  /// يحوّل تسمية فترة الإيجار (عربية أو مفردات الـ API) إلى مفتاح الـ Backend.
  static String _toPeriodKey(String? p) {
    switch ((p ?? '').trim()) {
      case 'يومياً':
      case 'daily':
        return 'daily';
      case 'سنوياً':
      case 'yearly':
        return 'yearly';
      default:
        return 'monthly';
    }
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