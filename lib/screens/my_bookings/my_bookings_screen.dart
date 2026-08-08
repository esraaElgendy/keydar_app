import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/booking_controllers.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/booking.dart';
import '../../data/services/property_image_resolver.dart';
import '../../widgets/property_image.dart';

/// حجوزات المستأجر — تسحب من `GET /customers/bookings` عبر [MyBookingsController].
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final MyBookingsController _controller = MyBookingsController();

  static const _tabLabels = {
    'all': 'الكل',
    'pending': 'قيد الانتظار',
    'confirmed': 'مؤكدة',
    'completed': 'مكتملة',
    'cancelled': 'ملغاة',
  };

  @override
  void initState() {
    super.initState();
    if (AuthController.instance.isLoggedIn) {
      _controller.load();
    }
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
      body: !AuthController.instance.isLoggedIn ? _buildLoginPrompt() : _buildContent(),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 56, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text('سجّل الدخول لعرض حجوزاتك',
              style: TextStyle(fontSize: 15, color: AppColors.black, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Obx(() {
            return Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 24,
              runSpacing: 6,
              children: [
                for (final s in MyBookingsController.statusTabs)
                  _StatusTab(
                    label: _tabLabels[s] ?? s,
                    selected: _controller.status.value == s,
                    onTap: () => _controller.selectStatus(s),
                  ),
              ],
            );
          }),
        ),
        Expanded(
          child: Obx(() {
            if (_controller.loading.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47C9)));
            }
            if (_controller.bookings.isEmpty) {
              return Center(
                child: Text(_controller.errorMessage.value ?? 'لا توجد حجوزات',
                    style: TextStyle(fontSize: 14, color: AppColors.grey)),
              );
            }
            return RefreshIndicator(
              onRefresh: () => _controller.load(),
              color: const Color(0xFF0D47C9),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _controller.bookings.length + (_controller.hasMore ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i >= _controller.bookings.length) {
                    _controller.loadMore();
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D47C9))),
                    );
                  }
                  final booking = _controller.bookings[i];
                  return _BookingCard(
                    booking: booking,
                    onTap: () => Get.toNamed(AppRoutes.bookingDetail, arguments: booking.id),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// تبويب نصّي: المحدَّد يظهر باللون الأزرق مع خط أكبر وأثقل وتسطير تحته.
class _StatusTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _StatusTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: selected ? 16 : 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? const Color(0xFF0D47C9) : AppColors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: selected ? 32 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0D47C9) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  const _BookingCard({required this.booking, required this.onTap});

  (Color fg, Color bg) get _palette {
    switch (booking.status) {
      case 'cancelled':
        return (const Color(0xFFD32F2F), const Color(0xFFFFEBEE));
      case 'completed':
        return (const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
      case 'confirmed':
        return (const Color(0xFF0D47C9), const Color(0xFFE3EDF7));
      case 'pending':
      default:
        return (const Color(0xFFE65100), const Color(0xFFFFF3E0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  _BookingImage(booking: booking),
                  PositionedDirectional(
                    top: 12, end: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(booking.status == 'pending' ? Icons.access_time : Icons.check_circle,
                              size: 14, color: fg),
                          const SizedBox(width: 4),
                          Text(booking.statusLabel,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
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
                  Text(booking.propertyTitle,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Color(0xFF0D47C9)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(booking.propertyLocation,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF0D47C9))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${booking.priceLabel} ر.س',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47C9))),
                          Text(booking.nights > 0 ? '${booking.nights} ليال' : '/ حجز',
                              style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.7))),
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
                            Text(booking.dateRange,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0D47C9).withValues(alpha: 0.7))),
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
      ),
    );
  }
}

class _BookingImage extends StatefulWidget {
  final Booking booking;
  const _BookingImage({required this.booking});

  @override
  State<_BookingImage> createState() => _BookingImageState();
}

class _BookingImageState extends State<_BookingImage> {
  String? _url;

  @override
  void initState() {
    super.initState();
    _url = AppConfig.assetUrl(widget.booking.propertyImageUrl);
    if (_url != null && _url!.isNotEmpty) return;
    final found = PropertyImageResolver.find(widget.booking.propertyId);
    _url = AppConfig.assetUrl(found);
    if (_url == null || _url!.isEmpty) {
      PropertyImageResolver.resolve(widget.booking.propertyId).then((resolved) {
        if (!mounted || resolved == null || resolved.isEmpty) return;
        setState(() => _url = AppConfig.assetUrl(resolved));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PropertyImage(imageUrl: _url, height: 160, width: double.infinity);
  }
}