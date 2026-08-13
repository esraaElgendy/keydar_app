import '../../core/constants/app_config.dart';
import '../models/booking.dart';
import '../services/api_client.dart';

/// طبقة الوصول لحجوزات الـ API (إنشاء / قائمة / تفاصيل / إلغاء).
class BookingRepository {
  final ApiClient _api = ApiClient.instance;

  /// إنشاء حجز جديد. يتطلب تسجيل دخول.
  Future<Booking> createBooking(CreateBookingRequest request) async {
    final res = await _api.post(AppConfig.createBooking, body: request.toJson());
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    final booking = data['booking'];
    if (booking is! Map) {
      throw const FormatException('استجابة غير صالحة');
    }
    return Booking.fromJson(Map<String, dynamic>.from(booking));
  }

  /// حجوزات المستأجر الحالي. يتطلب تسجيل دخول.
  /// [status] فلاتر مثل `all`, `pending`, `confirmed`, `completed`, `cancelled`.
  Future<BookingPage> fetchMyBookings({
    String status = 'all',
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _api.get(
      AppConfig.myBookings,
      query: {'limit': limit, 'page': page, 'status': status},
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    return BookingPage.fromJson(data);
  }

  /// تفاصيل حجز واحد.
  Future<Booking> fetchBookingDetail({required int id}) async {
    final res = await _api.get(AppConfig.bookingDetail(id));
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    final booking = data['booking'];
    if (booking is! Map) {
      throw const FormatException('استجابة غير صالحة');
    }
    return Booking.fromJson(Map<String, dynamic>.from(booking));
  }

  /// إلغاء حجز. يتطلب تسجيل دخول.
  Future<CancelBookingResult> cancelBooking({required int id}) async {
    final res = await _api.post(AppConfig.cancelBooking(id));
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    return CancelBookingResult.fromJson(data);
  }

  // ===== Owner Bookings =====

  /// حجوزات المالك من `/owner/bookings` — يتطلب تسجيل دخول المالك.
  /// [status] قيم مثل `all`, `pending`, `confirmed`, `cancelled`.
  /// [propertyId]: `all` لكل العقارات أو رقم عقار محدد.
  Future<BookingPage> fetchOwnerBookings({
    String status = 'all',
    String propertyId = 'all',
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _api.get(
      AppConfig.ownerBookings,
      query: {
        'limit': limit,
        'page': page,
        'status': status,
        'propertyId': propertyId,
      },
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    return BookingPage.fromJson(data);
  }

  /// تفاصيل حجز من منظور المالك `/owner/bookings/{id}`.
  Future<Booking> fetchOwnerBookingDetail({required int id}) async {
    final res = await _api.get(AppConfig.ownerBookingDetail(id));
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    final booking = data['booking'];
    if (booking is! Map) {
      throw const FormatException('استجابة غير صالحة');
    }
    return Booking.fromJson(Map<String, dynamic>.from(booking));
  }
}