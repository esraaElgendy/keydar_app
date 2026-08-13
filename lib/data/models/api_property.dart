import '../../core/constants/app_config.dart';
import '../../models/property.dart';

/// يمثّل عقاراً كما يأتي من الـ API (`GET /properties/latest`).
/// هذه الطبقة تفصل الـ JSON عن موديل الواجهة [Property].
class ApiProperty {
  final int? id;
  final String? image;
  final List<String> images;
  final String? tag;
  final String? propertyType;
  final String? status;
  final String? approvalStatus;
  final String? furnishing;
  final String? city;
  final String title;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double rating;
  final int beds;
  final int baths;
  final int guests;
  final num area;
  final String price;
  final String? period;
  final Map<String, num>? prices;
  final bool isFavorite;
  final String? description;

  const ApiProperty({
    this.id,
    this.image,
    this.images = const [],
    this.tag,
    this.propertyType,
    this.status,
    this.approvalStatus,
    this.furnishing,
    this.city,
    required this.title,
    this.location,
    this.latitude,
    this.longitude,
    this.rating = 0,
    this.beds = 0,
    this.baths = 0,
    this.guests = 0,
    this.area = 0,
    this.price = '0',
    this.period,
    this.prices,
    this.isFavorite = false,
    this.description,
  });

  factory ApiProperty.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'];
    final images = <String>[];
    if (imagesRaw is List) {
      for (final e in imagesRaw) {
        if (e is String && e.trim().isNotEmpty) {
          images.add(e);
        } else if (e is Map) {
          final src = e['src'];
          if (src is String && src.trim().isNotEmpty) images.add(src);
        }
      }
    }

    final pricesRaw = json['prices'];
    final Map<String, num> prices = {};
    if (pricesRaw is Map) {
      pricesRaw.forEach((key, value) {
        final n = _toNum(value);
        if (n == null || key is! String) return;
        prices[key] = n;
      });
    }

    return ApiProperty(
      id: (json['id'] as num?)?.toInt(),
      image: json['image'] as String?,
      images: images,
      tag: json['tag'] as String?,
      propertyType: json['propertyType'] as String?,
      status: json['status'] as String?,
      approvalStatus: json['approvalStatus'] as String?,
      furnishing: json['furnishing'] as String?,
      city: json['city'] as String?,
      title: (json['title'] as String?) ?? '',
      location: json['location'] as String?,
      latitude: _toNum(json['latitude'])?.toDouble(),
      longitude: _toNum(json['longitude'])?.toDouble(),
      rating: _toNum(json['score'])?.toDouble() ?? _toNum(json['rating'])?.toDouble() ?? 0,
      beds: _toNum(json['beds'])?.toInt() ?? 0,
      baths: _toNum(json['baths'])?.toInt() ?? 0,
      guests: _toNum(json['guests'])?.toInt() ?? 0,
      area: _toNum(json['area']) ?? 0,
      price: '${json['price'] ?? '0'}',
      period: json['period'] as String?,
      prices: prices,
      isFavorite: json['isFavorite'] == true,
      description: json['description'] as String?,
    );
  }

  static num? _toNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v.replaceAll(',', ''));
    return null;
  }

  /// اختيار سعر العرض حسب فترة الإيجار.
  String get displayPrice {
    if (prices != null && prices!.isNotEmpty) {
      final periodKey = period == 'شهرياً'
          ? 'monthly'
          : period == 'سنوياً'
              ? 'yearly'
              : 'daily';
      final v = prices![periodKey];
      if (v != null) return _formatPrice(v);
    }
    return _formatNum(num.tryParse(price.replaceAll(',', '')) ?? 0);
  }

  static String _formatPrice(num v) => _formatNum(v);

  static String _formatNum(num v) {
    final asInt = v.toInt();
    final s = asInt.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final remaining = s.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }

  /// تحويل الكائن الخام إلى موديل الواجهة [Property].
  Property toProperty() {
    final firstImage = AppConfig.assetUrl(image ?? (images.isNotEmpty ? images.first : null));
    return Property(
      id: id,
      title: title,
      type: propertyType ?? 'عقار',
      location: _friendlyLocation(),
      price: displayPrice,
      period: period ?? '',
      rating: rating,
      reviews: 0,
      bedrooms: beds,
      bathrooms: baths,
      area: area.toDouble(),
      image: '',
      description: description ?? furnishing ?? '',
      badge1: statusLabel,
      isFavorite: isFavorite,
      imageUrl: firstImage,
      gallery: images.map(AppConfig.assetUrl).where((u) => u.isNotEmpty).toList(),
      status: status,
      furnishing: furnishing,
      city: city,
      guests: guests,
      latitude: latitude,
      longitude: longitude,
      prices: prices,
    );
  }

  /// تحويل الحالة القادمة من السيرفر إلى تسمية الواجهة.
  /// `approvalStatus: pending` → "قيد المراجعة"، و `status: متاح` → "متاحة".
  String get statusLabel {
    final approval = (approvalStatus ?? '').toLowerCase();
    if (approval == 'pending') return 'قيد المراجعة';
    final s = (status ?? '').trim();
    if (s == 'متاح' || s == 'available') return 'متاحة';
    if (s == 'مؤجرة' || s == 'rented') return 'مؤجرة';
    if (s.isEmpty) return 'متاحة';
    return s;
  }

  /// عندما تكون المواقع على هيئة إحداثيات (`lat:/lng:`) نعرض نصاً مقروءاً.
  String _friendlyLocation() {
    final raw = (location ?? '').trim();
    final lower = raw.toLowerCase();
    if (lower.contains('lat:') || lower.contains('lng:') || lower.contains('latitude')) {
      return 'الموقع على الخريطة';
    }
    return raw;
  }
}

/// استجابة قائمة العقارات: تحتوي على مصفوفة `properties`.
class ApiPropertiesResponse {
  final List<ApiProperty> properties;

  const ApiPropertiesResponse({required this.properties});

  factory ApiPropertiesResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['properties'];
    if (raw is List) {
      return ApiPropertiesResponse(
        properties: raw
            .whereType<Map>()
            .map((e) => ApiProperty.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    }
    return const ApiPropertiesResponse(properties: []);
  }

  /// تحويل العقارات الخام إلى موديل الواجهة [Property].
  List<Property> toProperties() {
    return properties.map((api) => api.toProperty()).toList();
  }
}

/// تفاصيل عقار كاملة (`GET /properties/{id}`): تضيف الوصف والمرافق
/// والمواصفات التفصيلية وعدد التقييمات فوق بيانات [ApiProperty].
class ApiPropertyDetail {
  final ApiProperty base;
  final String? description;
  final int reviewsCount;
  final List<String> amenities;
  final String? floor;
  final int kitchens;
  final String? address;
  final String? createdAt;
  final List<String> kitchenAmenities;
  final List<String> bathroomAmenities;
  final List<String> primaryAmenities;
  final List<String> secondaryAmenities;
  final List<String> features;

  const ApiPropertyDetail({
    required this.base,
    this.description,
    this.reviewsCount = 0,
    this.amenities = const [],
    this.floor,
    this.kitchens = 0,
    this.address,
    this.createdAt,
    this.kitchenAmenities = const [],
    this.bathroomAmenities = const [],
    this.primaryAmenities = const [],
    this.secondaryAmenities = const [],
    this.features = const [],
  });

  factory ApiPropertyDetail.fromJson(Map<String, dynamic> json) {
    final specs = json['specs'] ?? json['specifications'];

    String? floor;
    int kitchens = 0;
    String? address;
    final kitchenAmenities = <String>[];
    final bathroomAmenities = <String>[];
    final primaryAmenities = <String>[];
    final secondaryAmenities = <String>[];
    final specFeatures = <String>[];

    if (specs is Map) {
      floor = specs['floor'] as String?;
      kitchens = (specs['kitchens'] as num?)?.toInt() ?? 0;
      address = specs['address'] as String?;
      kitchenAmenities.addAll(_stringList(specs['kitchen_amenities']));
      bathroomAmenities.addAll(_stringList(specs['bathroom_amenities']));
      primaryAmenities.addAll(_stringList(specs['primary_amenities']));
      secondaryAmenities.addAll(_stringList(specs['secondary_amenities']));
      specFeatures.addAll(_stringList(specs['property_features']));
    }

    if (kitchenAmenities.isEmpty) kitchenAmenities.addAll(_stringList(json['kitchenAmenities']));
    if (bathroomAmenities.isEmpty) bathroomAmenities.addAll(_stringList(json['bathroomAmenities']));
    if (primaryAmenities.isEmpty) primaryAmenities.addAll(_stringList(json['primaryAmenities']));
    if (secondaryAmenities.isEmpty) secondaryAmenities.addAll(_stringList(json['secondaryAmenities']));
    if (specFeatures.isEmpty) specFeatures.addAll(_stringList(json['propertyFeatures']));

    return ApiPropertyDetail(
      base: ApiProperty.fromJson(json),
      description: json['description'] as String?,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      amenities: _stringList(json['amenities']),
      floor: floor,
      kitchens: kitchens,
      address: address,
      createdAt: json['createdAt'] as String?,
      kitchenAmenities: kitchenAmenities,
      bathroomAmenities: bathroomAmenities,
      primaryAmenities: primaryAmenities,
      secondaryAmenities: secondaryAmenities,
      features: _stringList(json['features']).isNotEmpty
          ? _stringList(json['features'])
          : specFeatures,
    );
  }

  /// يدمج التفاصيل فوق بيانات العقار الأساسية.
  Property toProperty() {
    final baseProp = base.toProperty();
    return baseProp.copyWith(
      description: description ?? baseProp.description,
      reviewsCount: reviewsCount,
      amenities: amenities,
      floor: floor,
      kitchenAmenities: kitchenAmenities,
      bathroomAmenities: bathroomAmenities,
      primaryAmenities: primaryAmenities,
      secondaryAmenities: secondaryAmenities,
      features: features,
    );
  }

  static List<String> _stringList(dynamic v) {
    if (v is! List) return const <String>[];
    return v
        .where((e) => e is String && e.trim().isNotEmpty)
        .map((e) => (e as String).trim())
        .toList();
  }
}

/// استجابة تفاصيل عقار: تحتوي على كائن `property`.
class ApiPropertyDetailResponse {
  final ApiPropertyDetail detail;

  const ApiPropertyDetailResponse({required this.detail});

  factory ApiPropertyDetailResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['property'];
    if (raw is Map) {
      return ApiPropertyDetailResponse(
        detail: ApiPropertyDetail.fromJson(Map<String, dynamic>.from(raw)),
      );
    }
    throw const FormatException('استجابة غير صالحة');
  }

  Property toProperty() => detail.toProperty();
}