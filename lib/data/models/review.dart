/// تقييم واحد لعقار من الـ API (`GET /properties/{id}/reviews`).
class PropertyReview {
  final int id;
  final String author;
  final double rating;
  final String? title;
  final String text;
  final DateTime? date;
  final bool verified;
  final int helpful;

  const PropertyReview({
    required this.id,
    required this.author,
    required this.rating,
    this.title,
    required this.text,
    this.date,
    this.verified = false,
    this.helpful = 0,
  });

  factory PropertyReview.fromJson(Map<String, dynamic> json) {
    final created = json['date'] ?? json['created_at'] ?? json['updated_at'];
    return PropertyReview(
      id: (json['id'] as num?)?.toInt() ?? 0,
      author: (json['author'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      title: json['title'] as String?,
      text: (json['text'] as String?) ?? '',
      date: created is String ? DateTime.tryParse(created) : null,
      verified: json['verified'] == true,
      helpful: (json['helpful'] as num?)?.toInt() ?? 0,
    );
  }

  PropertyReview copyWith({int? helpful}) => PropertyReview(
        id: id,
        author: author,
        rating: rating,
        title: title,
        text: text,
        date: date,
        verified: verified,
        helpful: helpful ?? this.helpful,
      );
}

/// صفحة تقييمات + ملخص التقييم العام للعقار.
class ReviewsPage {
  final List<PropertyReview> reviews;
  final int page;
  final int limit;
  final int total;
  final int pages;
  final double averageRating;
  final int totalReviews;

  const ReviewsPage({
    required this.reviews,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
    required this.averageRating,
    required this.totalReviews,
  });

  factory ReviewsPage.fromJson(Map<String, dynamic> json) {
    final page = json['pagination'];
    final reviewList = json['reviews'];
    return ReviewsPage(
      reviews: reviewList is List
          ? reviewList
              .whereType<Map>()
              .map((e) => PropertyReview.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      page: page is Map ? (page['page'] as num?)?.toInt() ?? 1 : 1,
      limit: page is Map ? (page['limit'] as num?)?.toInt() ?? 6 : 6,
      total: page is Map ? (page['total'] as num?)?.toInt() ?? 0 : 0,
      pages: page is Map ? (page['pages'] as num?)?.toInt() ?? 1 : 1,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
    );
  }
}