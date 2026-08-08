import 'package:get/get.dart';

import '../data/models/booking.dart';
import '../data/repositories/booking_repository.dart';
import 'auth_controller.dart';

/// إنشاء حجز جديد (شاشة تأكيد الحجز).
class CreateBookingController extends GetxController {
  final BookingRepository _repository = BookingRepository();

  final RxBool submitting = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<Booking> created = Rxn<Booking>();

  Future<bool> submit(CreateBookingRequest request) async {
    submitting.value = true;
    errorMessage.value = null;
    try {
      final booking = await _repository.createBooking(request);
      created.value = booking;
      AuthController.instance.fetchStatistics();
      return true;
    } catch (e) {
      errorMessage.value = 'تعذر تأكيد الحجز، تحقق من اتصالك وحاول مرة أخرى';
      return false;
    } finally {
      submitting.value = false;
    }
  }
}

/// سرد حجوزات المستأجر مع الفلترة والإلغاء.
class MyBookingsController extends GetxController {
  final BookingRepository _repository = BookingRepository();

  final RxList<Booking> bookings = RxList<Booking>();
  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxnString errorMessage = RxnString();
  final RxString status = RxString('all');
  final RxString cancellingId = RxString('');

  int _page = 1;
  int _pages = 1;
  bool _loaded = false;

  static const List<String> statusTabs = [
    'all', 'pending', 'confirmed', 'completed', 'cancelled',
  ];

  bool get hasMore => _loaded && _page < _pages;

  Future<void> load({bool silent = false}) async {
    if (!silent) loading.value = true;
    errorMessage.value = null;
    try {
      final result = await _repository.fetchMyBookings(status: status.value);
      bookings.assignAll(result.bookings);
      _page = result.page;
      _pages = result.pages;
      _loaded = true;
      if (bookings.isEmpty) {
        errorMessage.value = 'لا توجد حجوزات';
      }
    } catch (e) {
      errorMessage.value = 'تعذر تحميل الحجوزات، تحقق من اتصالك بالإنترنت';
    } finally {
      loading.value = false;
    }
  }

  Future<void> selectStatus(String s) async {
    if (status.value == s) return;
    status.value = s;
    _reset();
    await load();
  }

  Future<void> loadMore() async {
    if (!hasMore || loadingMore.value) return;
    loadingMore.value = true;
    try {
      final result = await _repository.fetchMyBookings(
        status: status.value,
        page: _page + 1,
      );
      bookings.addAll(result.bookings);
      _page = result.page;
      _pages = result.pages;
    } finally {
      loadingMore.value = false;
    }
  }

  /// إلغاء حجز. [id] رقم الحجز.
  Future<CancelBookingResult?> cancel({required int id}) async {
    cancellingId.value = '$id';
    try {
      final result = await _repository.cancelBooking(id: id);
      await load(silent: true);
      AuthController.instance.fetchStatistics();
      return result;
    } catch (e) {
      errorMessage.value = 'تعذر إلغاء الحجز، حاول مرة أخرى';
      return null;
    } finally {
      cancellingId.value = '';
    }
  }

  void _reset() {
    _page = 1;
    _pages = 1;
    _loaded = false;
  }
}

/// تفاصيل حجز واحد + الإلغاء.
class BookingDetailController extends GetxController {
  final BookingRepository _repository = BookingRepository();

  final Rxn<Booking> booking = Rxn<Booking>();
  final RxBool loading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool cancelling = false.obs;

  Future<void> load({required int id}) async {
    loading.value = true;
    errorMessage.value = null;
    try {
      booking.value = await _repository.fetchBookingDetail(id: id);
    } catch (e) {
      errorMessage.value = 'تعذر تحميل تفاصيل الحجز';
    } finally {
      loading.value = false;
    }
  }

  Future<CancelBookingResult?> cancel() async {
    final current = booking.value;
    if (current == null) return null;
    cancelling.value = true;
    try {
      final result = await _repository.cancelBooking(id: current.id);
      booking.value = current.copyWith(status: 'cancelled');
      AuthController.instance.fetchStatistics();
      return result;
    } catch (e) {
      errorMessage.value = 'تعذر إلغاء الحجز، حاول مرة أخرى';
      return null;
    } finally {
      cancelling.value = false;
    }
  }
}