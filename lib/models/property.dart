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
  });
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
