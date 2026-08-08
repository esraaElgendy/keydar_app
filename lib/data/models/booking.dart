/// حجز من الـ API (قائمة/تفاصيل/إنشاء).
class Booking {
  final int id;
  final String bookingNumber;
  final int? propertyId;
  final String propertyTitle;
  final String propertyLocation;
  final String? propertyImage;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int nights;
  final int guests;
  final String status;
  final String paymentStatus;
  final num totalPrice;
  final DateTime? createdAt;

  const Booking({
    required this.id,
    required this.bookingNumber,
    this.propertyId,
    this.propertyTitle = '',
    this.propertyLocation = '',
    this.propertyImage,
    this.checkInDate,
    this.checkOutDate,
    this.nights = 0,
    this.guests = 0,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.totalPrice = 0,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final prop = json['property'];
    return Booking(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bookingNumber: (json['bookingNumber'] as String?) ?? '#BK',
      propertyId: prop is Map ? (prop['id'] as num?)?.toInt() : null,
      propertyTitle: prop is Map ? (prop['title'] as String?) ?? '' : '',
      propertyLocation: prop is Map ? (prop['location'] as String?) ?? '' : '',
      propertyImage: prop is Map ? prop['image'] as String? : null,
      checkInDate: _tryParse(json['checkInDate']),
      checkOutDate: _tryParse(json['checkOutDate']),
      nights: (json['nights'] as num?)?.toInt() ?? 0,
      guests: (json['guests'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'pending',
      paymentStatus: (json['paymentStatus'] as String?) ?? 'pending',
      totalPrice: (json['totalPrice'] as num?) ?? 0,
      createdAt: _tryParseDateTime(json['createdAt']),
    );
  }

  static DateTime? _tryParse(dynamic v) {
    if (v is String) {
      final d = DateTime.tryParse(v);
      if (d != null) return DateTime(d.year, d.month, d.day);
    }
    return null;
  }

  static DateTime? _tryParseDateTime(dynamic v) {
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  // ---- عرض الحالة بالعربية ----
  String get statusLabel => _label(status, {
        'pending': 'قيد الانتظار',
        'confirmed': 'مؤكدة',
        'completed': 'مكتملة',
        'cancelled': 'ملغاة',
      });

  String get paymentLabel => _label(paymentStatus, {
        'pending': 'غير مدفوع',
        'paid': 'مدفوع',
        'refunded': 'مُرد',
      });

  /// صورة العقار كما تصل من الـ API — قد تكون `null` داخل كائن الحجز.
  String? get propertyImageUrl => propertyImage;

  bool get isCancellable => status == 'pending' || status == 'confirmed';
  bool get isCancelled => status == 'cancelled';

  String get dateRange {
    String fmt(DateTime? d) {
      if (d == null) return '';
      return '${d.day} ${_months[d.month - 1]}';
    }

    final a = checkInDate;
    final b = checkOutDate;
    if (a == null || b == null) return '';
    return '${fmt(a)} - ${fmt(b)}';
  }

  String get priceLabel => _format(totalPrice);

  Booking copyWith({
    int? id,
    String? bookingNumber,
    int? propertyId,
    String? propertyTitle,
    String? propertyLocation,
    String? propertyImage,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? nights,
    int? guests,
    String? status,
    String? paymentStatus,
    num? totalPrice,
    DateTime? createdAt,
  }) =>
      Booking(
        id: id ?? this.id,
        bookingNumber: bookingNumber ?? this.bookingNumber,
        propertyId: propertyId ?? this.propertyId,
        propertyTitle: propertyTitle ?? this.propertyTitle,
        propertyLocation: propertyLocation ?? this.propertyLocation,
        propertyImage: propertyImage ?? this.propertyImage,
        checkInDate: checkInDate ?? this.checkInDate,
        checkOutDate: checkOutDate ?? this.checkOutDate,
        nights: nights ?? this.nights,
        guests: guests ?? this.guests,
        status: status ?? this.status,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        totalPrice: totalPrice ?? this.totalPrice,
        createdAt: createdAt ?? this.createdAt,
      );

  static String _label(String value, Map<String, String> map) {
    final normalized = value.toLowerCase();
    return map[normalized] ?? value;
  }

  static String _format(num v) {
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

  static const _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
}

/// صفحة حجوزات (قائمة + تنقيل).
class BookingPage {
  final List<Booking> bookings;
  final int page;
  final int limit;
  final int total;
  final int pages;

  const BookingPage({
    required this.bookings,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory BookingPage.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'];
    final list = json['bookings'];
    return BookingPage(
      bookings: list is List
          ? list
              .whereType<Map>()
              .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      page: pagination is Map ? (pagination['page'] as num?)?.toInt() ?? 1 : 1,
      limit: pagination is Map ? (pagination['limit'] as num?)?.toInt() ?? 50 : 50,
      total: pagination is Map ? (pagination['total'] as num?)?.toInt() ?? 0 : 0,
      pages: pagination is Map ? (pagination['pages'] as num?)?.toInt() ?? 1 : 1,
    );
  }
}

/// طلب إنشاء حجز جديد.
class CreateBookingRequest {
  final int propertyId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String checkInTime;
  final String checkOutTime;
  final int nights;
  final int guests;
  final num totalPrice;
  final String? notes;

  const CreateBookingRequest({
    required this.propertyId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.nights,
    required this.guests,
    required this.totalPrice,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'propertyId': propertyId,
        'checkInDate': _date(checkInDate),
        'checkOutDate': _date(checkOutDate),
        'checkInTime': checkInTime,
        'checkOutTime': checkOutTime,
        'nights': nights,
        'guests': guests,
        'totalPrice': totalPrice,
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      };

  static String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// نتيجة إلغاء حجز.
class CancelBookingResult {
  final bool success;
  final String message;
  final num? refundAmount;

  const CancelBookingResult({required this.success, required this.message, this.refundAmount});

  factory CancelBookingResult.fromJson(Map<String, dynamic> json) => CancelBookingResult(
        success: json['success'] == true,
        message: (json['message'] as String?) ?? '',
        refundAmount: json['refundAmount'] as num?,
      );
}