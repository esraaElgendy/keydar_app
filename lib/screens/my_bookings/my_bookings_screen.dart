import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/booking.dart';
import '../../models/sample_data.dart';
import '../../widgets/bottom_nav.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Spacer(),
                  Expanded(
                    child: Center(
                      child: Text(
                        'الحجوزات',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_forward, color: AppColors.black, size: 24),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              dividerColor: AppColors.fieldBorder,
              tabs: const [
                Tab(text: 'القادمة'),
                Tab(text: 'المكتملة'),
                Tab(text: 'الملغاة'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList([BookingStatus.current, BookingStatus.upcoming]),
                  _buildList([BookingStatus.completed]),
                  _buildList([BookingStatus.cancelled]),
                ],
              ),
            ),
            AppBottomNav(currentIndex: 2, onTap: (i) {
              switch (i) {
                case 0: Get.offNamed(AppRoutes.home);
                case 1: Get.offNamed(AppRoutes.explore);
                case 2: break;
                case 3: Get.offNamed(AppRoutes.favorites);
                case 4: Get.offNamed(AppRoutes.profile);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<BookingStatus> statuses) {
    final items = sampleBookings.where((b) => statuses.contains(b.status)).toList();
    if (items.isEmpty) {
      return Center(child: Text('لا توجد حجوزات', style: TextStyle(fontSize: 14, color: AppColors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.propertyDetails, arguments: SampleData.properties[0]),
          child: _BookingCard(booking: items[i]),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  Color get _badgeBg {
    switch (booking.status) {
      case BookingStatus.current: return const Color(0xFFE8F5E9);
      case BookingStatus.upcoming: return const Color(0xFFE3F2FD);
      case BookingStatus.completed: return const Color(0xFFE8F5E9);
      case BookingStatus.cancelled: return const Color(0xFFFCE4EC);
    }
  }

  Color get _badgeTextColor {
    switch (booking.status) {
      case BookingStatus.current: return const Color(0xFF2E7D32);
      case BookingStatus.upcoming: return const Color(0xFF1565C0);
      case BookingStatus.completed: return const Color(0xFF2E7D32);
      case BookingStatus.cancelled: return const Color(0xFFC62828);
    }
  }

  IconData? get _badgeIcon {
    switch (booking.status) {
      case BookingStatus.current: return Icons.access_time;
      case BookingStatus.upcoming: return Icons.access_time;
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Image.asset(booking.image, height: 140, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 140, color: AppColors.fieldBorder,
                    child: const Icon(Icons.image_outlined, color: AppColors.grey, size: 40),
                  ),
                ),
                Positioned(top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _badgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(booking.badgeText,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _badgeTextColor)),
                        if (_badgeIcon != null) ...[
                          const SizedBox(width: 4),
                          Icon(_badgeIcon, size: 12, color: _badgeTextColor),
                        ],
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
                Text(booking.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(booking.location,
                      style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                    const SizedBox(width: 4),
                    const Icon(Icons.location_on, color: AppColors.primary, size: 14),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(booking.dateRange,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                              color: AppColors.primary.withValues(alpha: 0.8))),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${booking.price} ر.س',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        Text('/ ${booking.period}',
                          style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.6))),
                      ],
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
