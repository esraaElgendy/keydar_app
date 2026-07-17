import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['القادمة', 'المكتملة', 'الملغاة'];

  static const _upcoming = [
    _TenantBooking(
      imageAsset: 'assets/image/building.jpg',
      status: 'جاري الآن',
      title: 'شقة مودرن مطلة على البحر',
      location: 'حي الشاطئ، جدة',
      price: '6,500',
      dateRange: '29 أكتوبر - 31 أكتوبر',
      statusColor: Color(0xFF2E7D32),
      badgeBg: Color(0xFFE8F5E9),
      showClock: true,
    ),
    _TenantBooking(
      imageAsset: 'assets/image/building.jpg',
      status: 'قادمة',
      title: 'شقة مودرن مطلة على البحر',
      location: 'حي الشاطئ، جدة',
      price: '6,500',
      dateRange: '29 أكتوبر - 31 أكتوبر',
      statusColor: Color(0xFF0D47C9),
      badgeBg: Color(0xFFE3EDF7),
      showClock: true,
    ),
  ];

  static const _completed = [
    _TenantBooking(
      imageAsset: 'assets/image/building.jpg',
      status: 'مكتملة',
      title: 'شقة مودرن مطلة على البحر',
      location: 'حي الشاطئ، جدة',
      price: '6,500',
      dateRange: '29 أكتوبر - 31 أكتوبر',
      statusColor: Color(0xFF2E7D32),
      badgeBg: Color(0xFFE8F5E9),
      showClock: false,
    ),
  ];

  static const _cancelled = [
    _TenantBooking(
      imageAsset: 'assets/image/building.jpg',
      status: 'ملغية',
      title: 'شقة مودرن مطلة على البحر',
      location: 'حي الشاطئ، جدة',
      price: '6,500',
      dateRange: '29 أكتوبر - 31 أكتوبر',
      statusColor: Color(0xFFD32F2F),
      badgeBg: Color(0xFFFFEBEE),
      showClock: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0D47C9),
              unselectedLabelColor: AppColors.grey,
              indicatorColor: const Color(0xFF0D47C9),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              dividerColor: const Color(0xFFE2E8F0),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [0, 1, 2].map((i) {
                final items = [_upcoming, _completed, _cancelled][i];
                return items.isEmpty
                    ? Center(child: Text('لا توجد حجوزات', style: TextStyle(fontSize: 14, color: AppColors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (_, index) => _BookingCard(booking: items[index]),
                      );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TenantBooking {
  final String imageAsset;
  final String status;
  final String title;
  final String location;
  final String price;
  final String dateRange;
  final Color statusColor;
  final Color badgeBg;
  final bool showClock;
  const _TenantBooking({
    required this.imageAsset,
    required this.status,
    required this.title,
    required this.location,
    required this.price,
    required this.dateRange,
    required this.statusColor,
    required this.badgeBg,
    required this.showClock,
  });
}

class _BookingCard extends StatelessWidget {
  final _TenantBooking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Image.asset(
                  b.imageAsset,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 180,
                    color: AppColors.darkBlue,
                    child: const Center(child: Icon(Icons.business, color: AppColors.white, size: 48)),
                  ),
                ),
                PositionedDirectional(
                  top: 12, end: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: b.badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (b.showClock) ...[
                          Icon(Icons.access_time, size: 14, color: b.statusColor),
                          const SizedBox(width: 4),
                        ],
                        Text(b.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: b.statusColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Color(0xFF0D47C9)),
                    const SizedBox(width: 4),
                    Text(b.location, style: const TextStyle(fontSize: 12, color: Color(0xFF0D47C9))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${b.price} ر.س', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47C9))),
                        Text('/ شهرياً', style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.7))),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: Color(0xFF0D47C9)),
                          const SizedBox(width: 4),
                          Text(b.dateRange, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0D47C9).withValues(alpha: 0.7))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Kept for backward compatibility with BookingDetailScreen
class BookingData {
  final String tenantName, title, location, price, period, status, dateRange;
  final String bookingDate, arrivalDate, departureDate;
  final String tenantEmail, tenantSince, tenantPhone;
  final Color statusColor, badgeBg;
  final int guestCount, nights;
  final double totalPrice, serviceFee, tax;
  const BookingData({
    required this.tenantName, required this.title, required this.location,
    required this.price, required this.period, required this.status,
    required this.statusColor, required this.badgeBg, required this.dateRange,
    required this.bookingDate, required this.arrivalDate, required this.departureDate,
    required this.guestCount, required this.nights,
    required this.totalPrice, required this.serviceFee, required this.tax,
    required this.tenantEmail, required this.tenantSince, required this.tenantPhone,
  });
}
