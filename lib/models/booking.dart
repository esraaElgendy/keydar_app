enum BookingStatus { upcoming, current, completed, cancelled }

class Booking {
  final String id;
  final String title;
  final String image;
  final String location;
  final String badgeText;
  final String price;
  final String period;
  final String dateRange;
  final BookingStatus status;

  const Booking({
    required this.id,
    required this.title,
    required this.image,
    required this.location,
    required this.badgeText,
    required this.price,
    required this.period,
    required this.dateRange,
    required this.status,
  });
}

final List<Booking> sampleBookings = [
  Booking(
    id: '1',
    title: 'شقة مودرن مطلة على البحر',
    image: 'assets/image/building.jpg',
    location: 'حي الشاطئ، جدة',
    badgeText: 'جاري الآن',
    price: '6,500',
    period: 'شهرياً',
    dateRange: '29 أكتوبر - 31 أكتوبر',
    status: BookingStatus.current,
  ),
  Booking(
    id: '2',
    title: 'فيلا فاخرة مع مسبح خاص',
    image: 'assets/image/building.jpg',
    location: 'الزهراء، الرياض',
    badgeText: 'قادمة',
    price: '6,500',
    period: 'شهرياً',
    dateRange: '29 أكتوبر - 31 أكتوبر',
    status: BookingStatus.upcoming,
  ),
  Booking(
    id: '3',
    title: 'شقة مودرن مطلة على البحر',
    image: 'assets/image/building.jpg',
    location: 'حي الشاطئ، جدة',
    badgeText: 'مكتملة',
    price: '6,500',
    period: 'شهرياً',
    dateRange: '29 أكتوبر - 31 أكتوبر',
    status: BookingStatus.completed,
  ),
  Booking(
    id: '4',
    title: 'شقة مودرن مطلة على البحر',
    image: 'assets/image/building.jpg',
    location: 'حي الشاطئ، جدة',
    badgeText: 'ملغية',
    price: '6,500',
    period: 'شهرياً',
    dateRange: '29 أكتوبر - 31 أكتوبر',
    status: BookingStatus.cancelled,
  ),
];
