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

  // ===== Search & Filters =====

  /// البحث في العقارات مع فلاتر ديناميكية — `GET /properties/search`.
  Future<SearchResult> searchProperties({
    String? search,
    String? city,
    String? type,
    int? rating,
    int? bedrooms,
    int? bathrooms,
    num? minPrice,
    num? maxPrice,
    String? sortBy,
    int page = 1,
    int limit = 12,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (city != null && city.isNotEmpty) query['city'] = city;
    if (type != null && type.isNotEmpty) query['type'] = type;
    if (rating != null && rating > 0) query['rating'] = rating;
    if (bedrooms != null && bedrooms > 0) query['bedrooms'] = bedrooms;
    if (bathrooms != null && bathrooms > 0) query['bathrooms'] = bathrooms;
    if (minPrice != null && minPrice > 0) query['minPrice'] = minPrice;
    if (maxPrice != null && maxPrice > 0) query['maxPrice'] = maxPrice;
    if (sortBy != null && sortBy.isNotEmpty) query['sortBy'] = sortBy;

    final res = await _api.get(AppConfig.propertySearch, query: query);
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      return const SearchResult(properties: [], total: 0, page: 1, pages: 1);
    }
    return SearchResult.fromJson(data);
  }

  /// خيارات الفلترة المتاحة من السيرفر — `GET /properties/filters`.
  Future<PropertyFilters> fetchPropertyFilters() async {
    final res = await _api.get(AppConfig.propertyFilters);
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      return const PropertyFilters();
    }
    return PropertyFilters.fromJson(data);
  }
}

/// نتيجة البحث مع التنقيل.
class SearchResult {
  final List<Property> properties;
  final int total;
  final int page;
  final int pages;

  const SearchResult({
    required this.properties,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final pagination = json['pagination'];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => ApiProperty.fromJson(Map<String, dynamic>.from(e)).toProperty())
            .toList()
        : const <Property>[];
    return SearchResult(
      properties: list,
      total: pagination is Map ? (pagination['total'] as num?)?.toInt() ?? 0 : 0,
      page: pagination is Map ? (pagination['page'] as num?)?.toInt() ?? 1 : 1,
      pages: pagination is Map ? (pagination['pages'] as num?)?.toInt() ?? 1 : 1,
    );
  }
}

/// خيارات الفلترة المتاحة من الباك-إند.
class PropertyFilters {
  final List<String> propertyTypes;
  final List<String> cities;
  final List<RatingFilter> ratings;
  final PriceRangeFilter? priceRange;

  const PropertyFilters({
    this.propertyTypes = const [],
    this.cities = const [],
    this.ratings = const [],
    this.priceRange,
  });

  factory PropertyFilters.fromJson(Map<String, dynamic> json) {
    final types = json['propertyTypes'];
    final citiesRaw = json['cities'];
    final ratingsRaw = json['ratings'];
    final priceRaw = json['priceRange'];
    return PropertyFilters(
      propertyTypes: types is List ? types.whereType<String>().toList() : const [],
      cities: citiesRaw is List ? citiesRaw.whereType<String>().toList() : const [],
      ratings: ratingsRaw is List
          ? ratingsRaw.whereType<Map>().map((e) => RatingFilter.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
      priceRange: priceRaw is Map ? PriceRangeFilter.fromJson(Map<String, dynamic>.from(priceRaw)) : null,
    );
  }
}

class RatingFilter {
  final String value;
  final int stars;
  const RatingFilter({required this.value, required this.stars});
  factory RatingFilter.fromJson(Map<String, dynamic> json) => RatingFilter(
        value: json['value'] as String? ?? '',
        stars: (json['stars'] as num?)?.toInt() ?? 0,
      );
}

class PriceRangeFilter {
  final num min;
  final num max;
  const PriceRangeFilter({this.min = 0, this.max = 1000});
  factory PriceRangeFilter.fromJson(Map<String, dynamic> json) => PriceRangeFilter(
        min: json['min'] as num? ?? 0,
        max: json['max'] as num? ?? 1000,
      );
}