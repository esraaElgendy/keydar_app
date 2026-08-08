/// إعدادات الاتصال بالباك إند
///
/// ضع هنا عنوان السيرفر و كل الـ endpoints المستخدمة.
/// عند تغيير السيرفر عدّل فقط قيمة [baseUrl].
class AppConfig {
  AppConfig._();

  /// عنوان السيرفر الرئيسي (بدون / في النهاية)
  static const String baseUrl = 'https://keydar-backend.atlas-data.sa/api';

  /// العنوان الذي تُخزَّن عليه ملفات الوسائط (بدون / في النهاية).
  static const String assetBaseUrl = 'https://keydar-backend.atlas-data.sa';

  /// يحوّل مسار وسائط من السيرفر إلى رابط كامل.
  /// مثال: `/storage/properties/x.jpg` → `https://.../storage/properties/x.jpg`
  static String assetUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$assetBaseUrl${path.startsWith('/') ? path : '/$path'}';
  }

  // ===== Auth - Customer =====
  static const String customerRegister = '/auth/customer-register';
  static const String customerLogin = '/auth/customer-login';
  static const String customerLogout = '/auth/customer-logout';

  // ===== Auth - Owner =====
  static const String ownerLogin = '/auth/owner-login';

  // ===== Properties =====
  static const String latestProperties = '/properties/latest';
  static const String allProperties = '/properties';
  static const String propertySearch = '/properties/search';

  /// تفاصيل عقار واحد.
  static String propertyDetail(int id) => '/properties/$id';

  /// تقييمات عقار (GET) وإضافة تقييم (POST) — محمية بـ auth عند الإضافة.
  static String propertyReviews(int id) => '/properties/$id/reviews';

  /// تمييز تقييم كمفيد (POST) — يتطلب تسجيل دخول.
  static String propertyReviewHelpful(int id, int reviewId) =>
      '/properties/$id/reviews/$reviewId/helpful';

  // ===== Customer =====
  static const String customerProfile = '/customers/profile';
  static const String customerStatistics = '/customers/statistics';
  static const String myBookings = '/customers/bookings';
  static const String favorites = '/customers/favorites';

  // ===== Bookings =====
  static const String createBooking = '/bookings';
  static const String bookAllBookings = '/bookings';

  /// تفاصيل حجز واحد.
  static String bookingDetail(int id) => '/bookings/$id';

  /// إلغاء حجز واحد.
  static String cancelBooking(int id) => '/bookings/$id/cancel';
}
