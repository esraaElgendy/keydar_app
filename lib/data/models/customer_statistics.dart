/// بيانات إحصائيات المستأجر كما تعود من `GET /customers/statistics`.
class CustomerStatistics {
  final int totalBookings;
  final int completedBookings;
  final int upcomingBookings;
  final double totalMoneySpent;
  final int favoriteProperties;

  const CustomerStatistics({
    required this.totalBookings,
    required this.completedBookings,
    required this.upcomingBookings,
    required this.totalMoneySpent,
    required this.favoriteProperties,
  });

  factory CustomerStatistics.fromJson(Map<String, dynamic> json) {
    return CustomerStatistics(
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      completedBookings: (json['completedBookings'] as num?)?.toInt() ?? 0,
      upcomingBookings: (json['upcomingBookings'] as num?)?.toInt() ?? 0,
      totalMoneySpent: (json['totalMoneySpent'] as num?)?.toDouble() ?? 0,
      favoriteProperties: (json['favoriteProperties'] as num?)?.toInt() ?? 0,
    );
  }
}