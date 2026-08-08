class Property {
  final String title;
  final String type;
  final String location;
  final String price;
  final String period;
  final double rating;
  final int reviews;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final String image;
  final String description;
  final String badge1;
  final String? badge2;
  final bool isFavorite;
  final List<String> amenities;

  /// حقول قادمة من الـ API — كلها اختيارية حتى لا نكسر البيانات المحلية.
  final int? id;
  final String? imageUrl;
  final List<String> gallery;
  final String? status;
  final String? furnishing;
  final int guests;
  final double? latitude;
  final double? longitude;
  final Map<String, num>? prices;

  /// تفاصيل إضافية من endpoint تفاصيل العقار.
  final int reviewsCount;
  final String? floor;
  final List<String> kitchenAmenities;
  final List<String> bathroomAmenities;
  final List<String> primaryAmenities;
  final List<String> secondaryAmenities;
  final List<String> features;

  const Property({
    required this.title,
    required this.type,
    required this.location,
    required this.price,
    required this.period,
    required this.rating,
    required this.reviews,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.image,
    required this.badge1,
    this.badge2,
    this.description = '',
    this.isFavorite = false,
    this.amenities = const [],
    this.id,
    this.imageUrl,
    this.gallery = const [],
    this.status,
    this.furnishing,
    this.guests = 0,
    this.latitude,
    this.longitude,
    this.prices,
    this.reviewsCount = 0,
    this.floor,
    this.kitchenAmenities = const [],
    this.bathroomAmenities = const [],
    this.primaryAmenities = const [],
    this.secondaryAmenities = const [],
    this.features = const [],
  });

  /// رابط الصورة الأساسي للعرض: الـ network إن وُجد وإلا المَورد المحلي.
  Property copyWith({
    bool? isFavorite,
    String? description,
    int? reviewsCount,
    String? floor,
    List<String>? kitchenAmenities,
    List<String>? bathroomAmenities,
    List<String>? primaryAmenities,
    List<String>? secondaryAmenities,
    List<String>? features,
    List<String>? amenities,
  }) {
    return Property(
      title: title,
      type: type,
      location: location,
      price: price,
      period: period,
      rating: rating,
      reviews: reviews,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      area: area,
      image: image,
      description: description ?? this.description,
      badge1: badge1,
      badge2: badge2,
      isFavorite: isFavorite ?? this.isFavorite,
      amenities: amenities ?? this.amenities,
      id: id,
      imageUrl: imageUrl,
      gallery: gallery,
      status: status,
      furnishing: furnishing,
      guests: guests,
      latitude: latitude,
      longitude: longitude,
      prices: prices,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      floor: floor ?? this.floor,
      kitchenAmenities: kitchenAmenities ?? this.kitchenAmenities,
      bathroomAmenities: bathroomAmenities ?? this.bathroomAmenities,
      primaryAmenities: primaryAmenities ?? this.primaryAmenities,
      secondaryAmenities: secondaryAmenities ?? this.secondaryAmenities,
      features: features ?? this.features,
    );
  }
}

class Car {
  final String name;
  final String model;
  final String category;
  final String price;
  final String transmission;
  final String fuel;
  final int seats;
  final String image;
  final double rating;
  final bool isAvailable;
  final String description;

  const Car({
    required this.name,
    required this.model,
    required this.category,
    required this.price,
    required this.transmission,
    required this.fuel,
    required this.seats,
    required this.image,
    required this.rating,
    this.isAvailable = true,
    this.description = '',
  });
}

class Review {
  final String name;
  final String avatar;
  final String date;
  final double rating;
  final String comment;

  const Review({
    required this.name,
    required this.avatar,
    required this.date,
    required this.rating,
    required this.comment,
  });
}

class Category {
  final String name;
  final String icon;

  const Category({required this.name, required this.icon});
}
