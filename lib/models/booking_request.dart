class BookingRequest {
  final String id;
  final String tenantName;
  final String propertyName;
  final String propertyType;
  final String location;
  final String address;
  final String status;
  final String price;
  final String dateFrom;
  final String dateTo;
  final int nights;
  final String paymentStatus;
  final String paymentMethod;
  final String orderDate;
  final String depositAmount;

  const BookingRequest({
    required this.id,
    required this.tenantName,
    required this.propertyName,
    required this.propertyType,
    required this.location,
    required this.address,
    required this.status,
    required this.price,
    required this.dateFrom,
    required this.dateTo,
    required this.nights,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.orderDate,
    required this.depositAmount,
  });

  static const List<BookingRequest> samples = [
    BookingRequest(
      id: '#88214',
      tenantName: 'أحمد منصور',
      propertyName: 'شقة البركة',
      propertyType: 'شقة سكنية',
      location: 'الرياض، حي النرجس',
      address: 'الرياض، حي النرجس، شارع الملك فهد',
      status: 'قيد المراجعة',
      price: '4,500 ر.س',
      dateFrom: '12 أكتوبر',
      dateTo: '15 أكتوبر',
      nights: 3,
      paymentStatus: 'تم دفع العربون',
      paymentMethod: 'مدى',
      orderDate: '12 أكتوبر، 2023 10:30 ص',
      depositAmount: '1,500 ر.س',
    ),
    BookingRequest(
      id: '#88215',
      tenantName: 'نورة السعيد',
      propertyName: 'فيلا النرجس',
      propertyType: 'فيلا',
      location: 'الرياض، حي النرجس',
      address: 'الرياض، حي النرجس، شارع الأمير محمد',
      status: 'تم القبول',
      price: '12,000 ر.س',
      dateFrom: '20 أكتوبر',
      dateTo: '25 أكتوبر',
      nights: 5,
      paymentStatus: 'تم الدفع كامل',
      paymentMethod: 'تحويل بنكي',
      orderDate: '15 أكتوبر، 2023 2:00 م',
      depositAmount: '12,000 ر.س',
    ),
    BookingRequest(
      id: '#88216',
      tenantName: 'فهد الدوسري',
      propertyName: 'مكتب الملقا',
      propertyType: 'مكتب تجاري',
      location: 'الرياض، حي الملقا',
      address: 'الرياض، حي الملقا، طريق الملك عبدالله',
      status: 'تم الرفض',
      price: '8,000 ر.س',
      dateFrom: '1 نوفمبر',
      dateTo: '30 نوفمبر',
      nights: 30,
      paymentStatus: 'ملغي',
      paymentMethod: 'بطاقة ائتمان',
      orderDate: '28 أكتوبر، 2023 9:15 ص',
      depositAmount: '0 ر.س',
    ),
    BookingRequest(
      id: '#88217',
      tenantName: 'هند القحطاني',
      propertyName: 'استوديو العليا',
      propertyType: 'استوديو',
      location: 'الرياض، حي العليا',
      address: 'الرياض، حي العليا، شارع التخصصي',
      status: 'قيد المراجعة',
      price: '3,200 ر.س',
      dateFrom: '5 نوفمبر',
      dateTo: '10 نوفمبر',
      nights: 5,
      paymentStatus: 'انتظار الدفع',
      paymentMethod: 'مدى',
      orderDate: '1 نوفمبر، 2023 4:45 م',
      depositAmount: '1,000 ر.س',
    ),
    BookingRequest(
      id: '#88218',
      tenantName: 'يوسف الشمري',
      propertyName: 'دوبلكس أبحر',
      propertyType: 'دوبلكس',
      location: 'جدة، أبحر الشمالية',
      address: 'جدة، أبحر الشمالية، كورنيش جدة',
      status: 'تم القبول',
      price: '15,000 ر.س',
      dateFrom: '15 نوفمبر',
      dateTo: '20 نوفمبر',
      nights: 5,
      paymentStatus: 'تم دفع العربون',
      paymentMethod: 'تحويل بنكي',
      orderDate: '10 نوفمبر، 2023 11:30 ص',
      depositAmount: '5,000 ر.س',
    ),
  ];
}
