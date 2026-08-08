import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../data/models/booking.dart';
import '../../data/services/property_image_resolver.dart';
import '../my_bookings/booking_data.dart';
import '../../controllers/booking_controllers.dart';
import '../../widgets/property_image.dart';

/// تفاصيل حجز:
/// - إذا مرَّرنا `int` (معرّف الحجز) → سحب حي من `GET /bookings/{id}`.
/// - إذا مرَّرنا [BookingData] → العرض الثابت القديم (سلسلة المالك).
class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args is int) {
      return _LiveDetailScreen(id: args);
    }
    return _LegacyDetailView(data: args as BookingData?);
  }
}

class _LiveDetailScreen extends StatefulWidget {
  final int id;
  const _LiveDetailScreen({required this.id});

  @override
  State<_LiveDetailScreen> createState() => _LiveDetailScreenState();
}

class _LiveDetailScreenState extends State<_LiveDetailScreen> {
  final BookingDetailController _controller = BookingDetailController();

  @override
  void initState() {
    super.initState();
    _controller.load(id: widget.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('إلغاء الحجز', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من إلغاء هذا الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('تراجع', style: TextStyle(fontSize: 14, color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأكيد الإلغاء',
                style: TextStyle(fontSize: 14, color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await _controller.cancel();
    if (!mounted) return;
    if (result != null) {
      Get.snackbar('تم الإلغاء',
          result.message + (result.refundAmount != null ? ' — المبلغ المسترد: ${result.refundAmount!.toStringAsFixed(0)} ريال' : ''),
          backgroundColor: const Color(0xFFC62828));
    } else {
      Get.snackbar('تعذر الإلغاء', 'حاول مرة أخرى لاحقاً',
          backgroundColor: const Color(0xFFC62828));
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
        title: const Text('تفاصيل الحجز', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
      ),
      body: Obx(() {
        if (_controller.loading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47C9)));
        }
        final booking = _controller.booking.value;
        if (booking == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_controller.errorMessage.value ?? 'تعذر تحميل الحجز',
                    style: const TextStyle(fontSize: 14, color: AppColors.grey)),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _controller.load(id: widget.id),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        return _buildContent(booking);
      }),
    );
  }

  Widget _buildContent(Booking b) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBanner(booking: b),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _DetailImage(booking: b),
          ),
          const SizedBox(height: 16),
          Text(b.propertyTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(b.propertyLocation,
                    style: const TextStyle(fontSize: 14, color: AppColors.grey)),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.location_on, size: 16, color: AppColors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('رقم الحجز: ${b.bookingNumber}',
                style: const TextStyle(fontSize: 12, color: AppColors.grey)),
          ),
          const SizedBox(height: 20),
          _InfoCard(booking: b),
          const SizedBox(height: 16),
          _PaymentCard(booking: b),
          if (b.isCancellable) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _controller.cancelling.value ? null : _confirmCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC62828),
                  side: const BorderSide(color: Color(0xFFC62828)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _controller.cancelling.value
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC62828)))
                    : const Text('إلغاء الحجز', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Booking booking;
  const _StatusBanner({required this.booking});

  (Color fg, Color bg) get _palette => switch (booking.status) {
        'cancelled' => (const Color(0xFFD32F2F), const Color(0xFFFFEBEE)),
        'completed' => (const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
        'confirmed' => (const Color(0xFF0D47C9), const Color(0xFFE3EDF7)),
        _ => (const Color(0xFFE65100), const Color(0xFFFFF3E0)),
      };

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _palette;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: bg)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(booking.statusLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: fg)),
            const SizedBox(width: 8),
            Icon(booking.status == 'pending' ? Icons.access_time : Icons.check_circle, size: 16, color: fg),
          ],
        ),
      ),
    );
  }
}

class _DetailImage extends StatefulWidget {
  final Booking booking;
  const _DetailImage({required this.booking});

  @override
  State<_DetailImage> createState() => _DetailImageState();
}

class _DetailImageState extends State<_DetailImage> {
  String? _url;

  @override
  void initState() {
    super.initState();
    _url = AppConfig.assetUrl(widget.booking.propertyImage);
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
    return PropertyImage(imageUrl: _url, height: 200, width: double.infinity);
  }
}

class _InfoCard extends StatelessWidget {
  final Booking booking;
  const _InfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _InfoRow(icon: Icons.event_note, label: 'تاريخ الحجز', value: _fmt(booking.createdAt)),
          const Divider(height: 20, color: Color(0xFFF2F4F7)),
          _InfoRow(icon: Icons.calendar_today, label: 'تاريخ الوصول', value: _fmt(booking.checkInDate)),
          const Divider(height: 20, color: Color(0xFFF2F4F7)),
          _InfoRow(icon: Icons.calendar_today, label: 'تاريخ المغادرة', value: _fmt(booking.checkOutDate)),
          const Divider(height: 20, color: Color(0xFFF2F4F7)),
          _InfoRow(icon: Icons.nightlight_round, label: 'عدد الليالي', value: '${booking.nights} ليال'),
          const Divider(height: 20, color: Color(0xFFF2F4F7)),
          _InfoRow(icon: Icons.people, label: 'عدد الضيوف', value: '${booking.guests} ضيف'),
        ],
      ),
    );
  }

  static String _fmt(DateTime? d) {
    if (d == null) return '—';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _PaymentCard extends StatelessWidget {
  final Booking booking;
  const _PaymentCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.credit_card, size: 20, color: Color(0xFF0D47C9)),
              SizedBox(width: 8),
              Text('تفاصيل الدفع',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
            ],
          ),
          const SizedBox(height: 16),
          _PaymentRow(label: 'إجمالي السعر', value: '${booking.priceLabel} ريال'),
          const Divider(height: 16, color: Color(0xFFF2F4F7)),
          _PaymentRow(label: 'حالة الدفع', value: booking.paymentLabel),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0D47C9)),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A24))),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A24))),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label, value;
  const _PaymentRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A24))),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A24))),
      ],
    );
  }
}

/// العرض الثابت القديم (سلسلة المالك) — لا يمثل الـ API.
class _LegacyDetailView extends StatelessWidget {
  final BookingData? data;
  const _LegacyDetailView({this.data});

  @override
  Widget build(BuildContext context) {
    final b = data;
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
        title: const Text('تفاصيل الحجز', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
      ),
      body: Center(
        child: Text(b?.title ?? 'تفاصيل الحجز غير متاحة',
            style: const TextStyle(fontSize: 15, color: AppColors.grey)),
      ),
    );
  }
}