import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import 'booking_data.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  int _selectedTab = 0;

  static const _tabs = ['الكل', 'قيد الانتظار', 'مؤكد', 'ملغي'];

  static const _bookings = [
    BookingData(tenantName: 'أحمد محمد', title: 'شقة فاخرة في الرياض', location: 'الرياض، العليا', price: '3,200', period: 'ليلة', status: 'مؤكد', statusColor: Color(0xFF2E7D32), badgeBg: Color(0xFFE8F5E9), dateRange: '2024/07/20 - 2024/07/25', guestCount: 2, nights: 5, bookingDate: '2024/07/15', arrivalDate: '2024/07/20', departureDate: '2024/07/25', totalPrice: 3200, serviceFee: 320, tax: 160, tenantEmail: 'ahmed.m@gmail.com', tenantSince: 'يونيو 2023', tenantPhone: '+966 50 123 4567'),
    BookingData(tenantName: 'سارة خالد', title: 'فيلا مودرن في جدة', location: 'جدة، الشاطئ', price: '6,500', period: 'ليلة', status: 'قيد الانتظار', statusColor: Color(0xFFE65100), badgeBg: Color(0xFFFFF3E0), dateRange: '2024/08/10 - 2024/08/15', guestCount: 4, nights: 5, bookingDate: '2024/08/01', arrivalDate: '2024/08/10', departureDate: '2024/08/15', totalPrice: 6500, serviceFee: 650, tax: 325, tenantEmail: 'sara.k@gmail.com', tenantSince: 'مارس 2024', tenantPhone: '+966 55 987 6543'),
    BookingData(tenantName: 'محمد علي', title: 'شقة صغيرة في الدمام', location: 'الدمام، الحمراء', price: '2,200', period: 'ليلة', status: 'ملغي', statusColor: Color(0xFFC62828), badgeBg: Color(0xFFFFCDD2), dateRange: '2024/06/05 - 2024/06/10', guestCount: 1, nights: 5, bookingDate: '2024/05/20', arrivalDate: '2024/06/05', departureDate: '2024/06/10', totalPrice: 2200, serviceFee: 220, tax: 110, tenantEmail: 'mohamed.a@gmail.com', tenantSince: 'يناير 2024', tenantPhone: '+966 50 111 2222'),
    BookingData(tenantName: 'نورة عبدالله', title: 'استوديو في الرياض', location: 'الرياض، حي الملقا', price: '1,500', period: 'ليلة', status: 'مؤكد', statusColor: Color(0xFF2E7D32), badgeBg: Color(0xFFE8F5E9), dateRange: '2024/09/01 - 2024/09/05', guestCount: 1, nights: 4, bookingDate: '2024/08/20', arrivalDate: '2024/09/01', departureDate: '2024/09/05', totalPrice: 1500, serviceFee: 150, tax: 75, tenantEmail: 'noura.a@gmail.com', tenantSince: 'أبريل 2024', tenantPhone: '+966 54 333 4444'),
    BookingData(tenantName: 'فهد العتيبي', title: 'دوبلكس في جدة', location: 'جدة، أبحر الشمالية', price: '6,500', period: 'ليلة', status: 'قيد الانتظار', statusColor: Color(0xFFE65100), badgeBg: Color(0xFFFFF3E0), dateRange: '2024/10/10 - 2024/10/20', guestCount: 6, nights: 10, bookingDate: '2024/09/25', arrivalDate: '2024/10/10', departureDate: '2024/10/20', totalPrice: 6500, serviceFee: 650, tax: 325, tenantEmail: 'fahad.o@gmail.com', tenantSince: 'فبراير 2024', tenantPhone: '+966 53 555 6666'),
    BookingData(tenantName: 'هند السالم', title: 'شقة مفروشة في الخبر', location: 'الخبر، العقربية', price: '2,800', period: 'ليلة', status: 'مؤكد', statusColor: Color(0xFF2E7D32), badgeBg: Color(0xFFE8F5E9), dateRange: '2024/11/15 - 2024/11/20', guestCount: 3, nights: 5, bookingDate: '2024/11/01', arrivalDate: '2024/11/15', departureDate: '2024/11/20', totalPrice: 2800, serviceFee: 280, tax: 140, tenantEmail: 'hind.s@gmail.com', tenantSince: 'أغسطس 2024', tenantPhone: '+966 55 777 8888'),
    BookingData(tenantName: 'يوسف الراشد', title: 'فيلا مودرن في الرياض', location: 'الرياض، حي النرجس', price: '5,000', period: 'ليلة', status: 'ملغي', statusColor: Color(0xFFC62828), badgeBg: Color(0xFFFFCDD2), dateRange: '2024/07/01 - 2024/07/10', guestCount: 5, nights: 9, bookingDate: '2024/06/15', arrivalDate: '2024/07/01', departureDate: '2024/07/10', totalPrice: 5000, serviceFee: 500, tax: 250, tenantEmail: 'yousif.r@gmail.com', tenantSince: 'مايو 2024', tenantPhone: '+966 50 999 0000'),
  ];

  List<BookingData> get _filtered {
    if (_tabs[_selectedTab] == 'الكل') return _bookings;
    return _bookings.where((b) => b.status == _tabs[_selectedTab]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A24)),
            onPressed: () => Get.back(),
          ),
        ),
        title: const Text('الحجوزات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: List.generate(4, (i) {
                final isActive = i == _selectedTab;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF0D47C9) : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isActive ? null : Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isActive ? AppColors.white : const Color(0xFF1A1A24),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: items.isEmpty
              ? Center(child: Text('لا توجد حجوزات', style: TextStyle(fontSize: 14, color: AppColors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final b = items[i];
                    return _BookingCard(
                      data: b,
                      onTap: () => Get.toNamed(AppRoutes.bookingDetail, arguments: b),
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingData data;
  final VoidCallback onTap;
  const _BookingCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final b = data;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.tenantName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                    const SizedBox(height: 4),
                    Text(b.title, style: const TextStyle(fontSize: 14, color: AppColors.grey)),
                    const SizedBox(height: 8),
                    Text('${b.price} SAR', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A24))),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: AppColors.grey),
                        const SizedBox(width: 6),
                        Text(b.dateRange, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/image/building.jpg',
                  width: 80, height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 80, height: 80,
                    color: AppColors.darkBlue,
                    child: const Icon(Icons.business, color: AppColors.white, size: 36),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: b.badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(b.status, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: b.statusColor)),
                    const SizedBox(width: 6),
                    b.status == 'قيد الانتظار'
                        ? Icon(Icons.access_time, size: 14, color: b.statusColor)
                        : Icon(Icons.check, size: 14, color: b.statusColor),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 34,
                child: OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0D47C9),
                    side: const BorderSide(color: Color(0xFF0D47C9)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text('التفاصيل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
