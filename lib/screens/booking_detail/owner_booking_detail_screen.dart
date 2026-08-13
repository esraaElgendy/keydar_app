import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controllers.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/booking.dart';

/// تفاصيل حجز من منظور المالك — `GET /owner/bookings/{id}`.
/// عرض منسّق: بطاقة رئيسية + أقسام واضحة للمستأجر والعقار والإقامة والدفع.
class OwnerBookingDetailScreen extends StatefulWidget {
  final int id;
  const OwnerBookingDetailScreen({super.key, required this.id});

  @override
  State<OwnerBookingDetailScreen> createState() => _OwnerBookingDetailScreenState();
}

class _OwnerBookingDetailScreenState extends State<OwnerBookingDetailScreen> {
  final OwnerBookingDetailController _controller = OwnerBookingDetailController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Color(0xFF1A1A24)),
            onPressed: () => Get.back(),
          ),
        ),
        title: const Text('تفاصيل الحجز', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
      ),
      body: Obx(() {
        if (_controller.loading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final booking = _controller.booking.value;
        if (booking == null) {
          return _buildErrorState(message: _controller.errorMessage.value ?? 'تعذر تحميل الحجز',
              onRetry: () => _controller.load(id: widget.id));
        }
        return _buildContent(booking);
      }),
    );
  }

  Widget _buildContent(Booking b) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroCard(booking: b),
          const SizedBox(height: 14),
          _SectionTitle(icon: Icons.person, title: 'بيانات المستأجر'),
          const SizedBox(height: 10),
          _CustomerCard(booking: b),
          const SizedBox(height: 20),
          _SectionTitle(icon: Icons.business, title: 'العقار'),
          const SizedBox(height: 10),
          _PropertyCard(booking: b),
          const SizedBox(height: 20),
          _SectionTitle(icon: Icons.event, title: 'تفاصيل الإقامة'),
          const SizedBox(height: 10),
          _StayCard(booking: b),
          const SizedBox(height: 20),
          _SectionTitle(icon: Icons.credit_card, title: 'تفاصيل الدفع'),
          const SizedBox(height: 10),
          _PaymentCard(booking: b),
          if (b.notes?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 20),
            _SectionTitle(icon: Icons.sticky_note_2, title: 'ملاحظات المستأجر'),
            const SizedBox(height: 10),
            _NotesCard(notes: b.notes!),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState({required String message, required VoidCallback onRetry}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: AppColors.grey),
          const SizedBox(height: 14),
          Text(message, style: const TextStyle(fontSize: 14, color: AppColors.grey)),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

/// بطاقة رئيسية بتدرج لوني: حالة الحجز + رقمه + السعر الإجمالي.
class _HeroCard extends StatelessWidget {
  final Booking booking;
  const _HeroCard({required this.booking});

  (Color fg, Color bg) get _palette => switch (booking.status) {
        'cancelled' => (const Color(0xFFC62828), const Color(0xFFFFEBEE)),
        'completed' => (const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
        'confirmed' => (const Color(0xFF0D47C9), const Color(0xFFE3EDF7)),
        _ => (const Color(0xFFE65100), const Color(0xFFFFF3E0)),
      };

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0D47C9), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: const Color(0xFF0D47C9).withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(booking.status == 'pending' ? Icons.access_time : Icons.check_circle, size: 14, color: fg),
                    const SizedBox(width: 5),
                    Text(booking.statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(booking.propertyTitle,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.confirmation_number, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Flexible(
                child:                 Text(booking.bookingNumber,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إجمالي الحجز',
                      style: TextStyle(fontSize: 11, color: Colors.white70)),
                  const SizedBox(height: 2),
                  Text('${booking.priceLabel} ر.س',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.nightlight_round, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text('${booking.nights} ليلة',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// عنوان قسم.
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
      ],
    );
  }
}

/// بطاقة المستأجر.
class _CustomerCard extends StatelessWidget {
  final Booking booking;
  const _CustomerCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.lightBlue],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(_initial(booking.customerName),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.customerName?.isNotEmpty == true ? booking.customerName! : 'عميل',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                      const SizedBox(height: 3),
                      Text('${booking.nights} ليالٍ · ${booking.guests} ضيوف',
                          style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (booking.customerEmail?.isNotEmpty == true || booking.customerPhone?.isNotEmpty == true)
            const Divider(height: 24, color: Color(0xFFF1F3F8)),
          if (booking.customerEmail?.isNotEmpty == true)
            _ContactRow(icon: Icons.email_outlined, value: booking.customerEmail!, valueColor: const Color(0xFF0D47C9)),
          if (booking.customerPhone?.isNotEmpty == true)
            _ContactRow(icon: Icons.phone_outlined, value: booking.customerPhone!),
        ],
      ),
    );
  }

  static String _initial(String? name) {
    if (name == null || name.isEmpty) return 'ع';
    return name.trim().substring(0, 1);
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color? valueColor;
  const _ContactRow({required this.icon, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: const Color(0xFFF3F6FC), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(value,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1A1A24))),
          ),
        ],
      ),
    );
  }
}

/// بطاقة العقار.
class _PropertyCard extends StatelessWidget {
  final Booking booking;
  const _PropertyCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0D47C9).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home_work, color: Color(0xFF0D47C9), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.propertyTitle,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(booking.propertyLocation,
                          style: const TextStyle(fontSize: 13, color: AppColors.grey, height: 1.4)),
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

/// بطاقة الإقامة (تواريخ الوصول/المغادرة والضيوف والليالي).
class _StayCard extends StatelessWidget {
  final Booking booking;
  const _StayCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // شريط التواريخ
          Row(
            children: [
              Expanded(
                child: _StayDate(label: 'الوصول', date: _fmt(booking.checkInDate),
                    color: const Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 8),
              const _Connector(),
              const SizedBox(width: 8),
              Expanded(
                child: _StayDate(label: 'المغادرة', date: _fmt(booking.checkOutDate),
                    color: const Color(0xFFD32F2F)),
              ),
            ],
          ),
          const Divider(height: 28, color: Color(0xFFF1F3F8)),
          Row(
            children: [
              Expanded(
                child: _MiniStat(icon: Icons.nightlight_round, label: 'عدد الليالي', value: '${booking.nights}'),
              ),
              Container(width: 1, height: 32, color: const Color(0xFFF1F3F8)),
              Expanded(
                child: _MiniStat(icon: Icons.people, label: 'عدد الضيوف', value: '${booking.guests}'),
              ),
              Container(width: 1, height: 32, color: const Color(0xFFF1F3F8)),
              Expanded(
                child: _MiniStat(icon: Icons.event_note, label: 'تاريخ الحجز', value: _fmtDayMonth(booking.createdAt)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime? d) {
    if (d == null) return '—';
    return '${d.year}/${d.month}/${d.day}';
  }

  static String _fmtDayMonth(DateTime? d) {
    if (d == null) return '—';
    return '${d.day}/${d.month}';
  }
}

class _StayDate extends StatelessWidget {
  final String label;
  final String date;
  final Color color;
  const _StayDate({required this.label, required this.date, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(date, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24, height: 24,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEFF1F6)),
      child: const Icon(Icons.arrow_forward, size: 13, color: AppColors.primary),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 4),
            Flexible(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24)))),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey)),
      ],
    );
  }
}

/// بطاقة الدفع.
class _PaymentCard extends StatelessWidget {
  final Booking booking;
  const _PaymentCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _PaymentRow(
            label: 'إجمالي السعر',
            value: '${booking.priceLabel} ر.س',
            valueColor: const Color(0xFF0D47C9),
            bold: true,
            fontSize: 16,
          ),
          const Divider(height: 20, color: Color(0xFFF1F3F8)),
          _PaymentRow(
            label: 'حالة الدفع',
            value: booking.paymentLabel,
            valueColor: _paymentColor(booking.paymentStatus),
          ),
          const SizedBox(height: 4),
          const Divider(height: 20, color: Color(0xFFF1F3F8)),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('يُحال الدفع مباشرة إليك بعد الحجز',
                    style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _paymentColor(String status) => switch (status.toLowerCase()) {
        'paid' => const Color(0xFF2E7D32),
        'refunded' => const Color(0xFFFF9800),
        _ => const Color(0xFFE65100),
      };
}

/// بطاقة الملاحظات.
class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFE9C7)),
        ),
        child: Text(notes, style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF6B4F00))),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool bold;
  final double fontSize;
  const _PaymentRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A24))),
        const Spacer(),
        Flexible(
          child: Text(value,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? const Color(0xFF1A1A24),
              )),
        ),
      ],
    );
  }
}

/// غلاف بطاقة أبيض موحّد.
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFF1F6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}