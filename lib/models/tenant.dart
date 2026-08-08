class Tenant {
  final String name, phone, email, property, propertyLocation, contractStatus, contractFrom, contractTo;
  final double rating, totalPayments;
  final int previousBookings;
  final String? imageUrl;

  const Tenant({
    required this.name,
    required this.phone,
    required this.email,
    required this.property,
    required this.propertyLocation,
    required this.contractStatus,
    required this.contractFrom,
    required this.contractTo,
    required this.rating,
    required this.totalPayments,
    required this.previousBookings,
    this.imageUrl,
  });
}

const tenants = [
  Tenant(
    name: 'أحمد محمد', phone: '+966 50 123 4567', email: 'ahmed.m@example.com',
    property: 'شقة فاخرة في الرياض', propertyLocation: 'الرياض، العليا',
    contractStatus: 'نشط', contractFrom: '2024/01/15', contractTo: '2024/07/15',
    rating: 4.9, totalPayments: 19200, previousBookings: 3,
  ),
  Tenant(
    name: 'سارة علي', phone: '+966 55 987 6543', email: 'sara.a@example.com',
    property: 'فيلا مودرن في جدة', propertyLocation: 'جدة، الشاطئ',
    contractStatus: 'منتهي', contractFrom: '2023/06/01', contractTo: '2024/06/01',
    rating: 4.8, totalPayments: 78000, previousBookings: 2,
  ),
  Tenant(
    name: 'خالد حسن', phone: '+966 50 111 2222', email: 'khalid.h@example.com',
    property: 'شقة مفروشة في الدمام', propertyLocation: 'الدمام، الحمراء',
    contractStatus: 'قيد الانتظار', contractFrom: '2024/08/01', contractTo: '2024/10/01',
    rating: 5.0, totalPayments: 0, previousBookings: 1,
  ),
  Tenant(
    name: 'نورة عبدالله', phone: '+966 54 333 4444', email: 'noura.a@example.com',
    property: 'استوديو في الرياض', propertyLocation: 'الرياض، حي الملقا',
    contractStatus: 'نشط', contractFrom: '2024/03/01', contractTo: '2024/09/01',
    rating: 4.7, totalPayments: 9000, previousBookings: 5,
  ),
  Tenant(
    name: 'فهد العتيبي', phone: '+966 53 555 6666', email: 'fahad.o@example.com',
    property: 'دوبلكس في جدة', propertyLocation: 'جدة، أبحر الشمالية',
    contractStatus: 'نشط', contractFrom: '2024/02/01', contractTo: '2025/02/01',
    rating: 4.6, totalPayments: 84000, previousBookings: 1,
  ),
];
