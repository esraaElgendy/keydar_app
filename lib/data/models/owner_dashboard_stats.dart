/// إحصائيات لوحة تحكم المالك (Owner Dashboard).
///
/// تعود من `GET /owner/dashboard/stats` داخل كائن `stats`.
class OwnerDashboardStats {
  final int totalProperties;
  final int activeProperties;
  final int totalBookings;
  final int pendingBookings;
  final double totalRevenue;
  final double monthlyRevenue;
  final int totalViews;
  final double averageRating;

  const OwnerDashboardStats({
    required this.totalProperties,
    required this.activeProperties,
    required this.totalBookings,
    required this.pendingBookings,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.totalViews,
    required this.averageRating,
  });

  factory OwnerDashboardStats.fromJson(Map<String, dynamic> json) {
    return OwnerDashboardStats(
      totalProperties: (json['totalProperties'] as num?)?.toInt() ?? 0,
      activeProperties: (json['activeProperties'] as num?)?.toInt() ?? 0,
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      pendingBookings: (json['pendingBookings'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] as num?)?.toDouble() ?? 0,
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
    );
  }
}