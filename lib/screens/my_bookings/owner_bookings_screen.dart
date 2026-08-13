import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/booking_controllers.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/booking.dart';
import '../booking_detail/owner_booking_detail_screen.dart';

/// حجوزات المالك — تسحب من `GET /owner/bookings` عبر [OwnerBookingsController].
class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  final OwnerBookingsController _controller = OwnerBookingsController();

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
    if (AuthController.instance.isOwnerLoggedIn) {
      _controller.load();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Get.back()),
            if (AuthController.instance.isOwnerLoggedIn) ...[
              _buildContent(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: Obx(() {
              if (_controller.loading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (_controller.bookings.isEmpty) {
                return _buildEmptyState(message: _controller.errorMessage.value ?? 'لا توجد حجوزات');
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _controller.load(),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: _controller.bookings.length + (_controller.hasMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i >= _controller.bookings.length) {
                      _controller.loadMore();
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                      );
                    }
                    final booking = _controller.bookings[i];
                    return _BookingCard(
                      booking: booking,
                      onTap: () => Get.to(() => OwnerBookingDetailScreen(id: booking.id)),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFF1F6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Obx(() {
        final tabs = OwnerBookingsController.statusTabs;
        final current = _controller.status.value;
        return Row(
          children: [
            for (final s in tabs) ...[
              Expanded(
                child: _TabPill(
                  label: _tabLabels[s] ?? s,
                  selected: current == s,
                  onTap: () => _controller.selectStatus(s),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState({required String message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88, height: 88,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEDF1F7)),
            child: const Icon(Icons.event_busy, size: 40, color: AppColors.grey),
          ),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 14, color: AppColors.grey)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _controller.load(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('إعادة التحميل'),
          ),
        ],
      ),
    );
  }
}

/// تبويب منزلق داخل شريط الحالة.
class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? AppColors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_forward, color: Color(0xFF1A1A24)),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text('حجوزاتي',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF0D47C9), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_note, color: Colors.white, size: 20),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── رأس: حالة + رقم الحجز ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(booking.status == 'pending' ? Icons.access_time : Icons.check_circle, size: 13, color: fg),
                          const SizedBox(width: 4),
                          Text(booking.statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(booking.bookingNumber,
                        style: TextStyle(fontSize: 11, color: const Color(0xFF1A1A24).withValues(alpha: 0.6))),
                  ],
                ),
                const SizedBox(height: 14),
                // ── المستأجر ──
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.lightBlue],
                        ),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initial(booking.customerName),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.customerName?.isNotEmpty == true ? booking.customerName! : 'عميل',
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                          if (booking.customerPhone?.isNotEmpty == true) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 12, color: AppColors.grey),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(booking.customerPhone!, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: const Color(0xFFF1F3F8),
                ),
                const SizedBox(height: 12),
                // ── العقار ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47C9).withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.business, color: Color(0xFF0D47C9), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.propertyTitle,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 13, color: AppColors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(booking.propertyLocation,
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // ── التواريخ ──
                Row(
                  children: [
                    Expanded(
                      child: _DateChip(
                        icon: Icons.event_available,
                        label: 'الوصول',
                        value: _fmt(booking.checkInDate),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _ArrowIcon(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DateChip(
                        icon: Icons.event_busy,
                        label: 'المغادرة',
                        value: _fmt(booking.checkOutDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── السعر + عدد الليالي ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerRight, end: Alignment.centerLeft,
                      colors: [Color(0xFFF0F4FF), Color(0xFFF8FAFF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('إجمالي الحجز', style: TextStyle(fontSize: 12, color: Color(0xFF1A1A24))),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D47C9).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${booking.nights} ليلة',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0D47C9))),
                      ),
                      const SizedBox(width: 10),
                      Text('${booking.priceLabel} ر.س',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47C9))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text('اضغط لعرض التفاصيل',
                      style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.6))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _initial(String? name) {
    if (name == null || name.isEmpty) return 'ع';
    return name.trim().substring(0, 1);
  }

  static String _fmt(DateTime? d) {
    if (d == null) return '—';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DateChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEFF1F6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, color: AppColors.grey)),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A1A24))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24, height: 24,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEFF1F6)),
      child: const Icon(Icons.arrow_forward, size: 13, color: AppColors.primary),
    );
  }
}