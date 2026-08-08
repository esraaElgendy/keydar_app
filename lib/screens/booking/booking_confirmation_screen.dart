import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/booking_controllers.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/booking.dart';
import '../../models/property.dart';
import '../../widgets/property_image.dart';

/// شاشة تأكيد الحجز: نموذج حجز ديناميكي يبني [CreateBookingRequest]
/// ويُرسِله إلى الـ API عبر [CreateBookingController].
class BookingConfirmationScreen extends StatefulWidget {
  /// العقار المراد حجزه (يُمرَّر من صفحة التفاصيل).
  final Property? property;
  const BookingConfirmationScreen({super.key, this.property});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final CreateBookingController _controller = CreateBookingController();
  final TextEditingController _notesController = TextEditingController();

  Property? get _property => widget.property ?? (Get.arguments is Property ? Get.arguments as Property : null);

  late DateTime _checkIn = _dayOnly(DateTime.now()).add(const Duration(days: 1));
  late DateTime _checkOut = _checkIn.add(const Duration(days: 6));
  TimeOfDay _checkInTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 12, minute: 0);
  late int _guests;

  @override
  void initState() {
    super.initState();
    final prop = _property;
    _guests = (prop?.guests != null && prop!.guests > 0) ? prop.guests : 2;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ---- الحسابات المالية ----
  /// السعر الأساسي لليلة الواحدة.
  int get _unitPrice {
    final prop = _property;
    final daily = prop?.prices?['daily'];
    if (daily != null && daily > 0) return daily.toInt();
    final monthly = prop?.prices?['monthly'];
    if (monthly != null && monthly > 0) return (monthly / 30).round();
    final parsed = _parseInt(prop?.price ?? '');
    if (parsed != null && parsed > 0) return parsed;
    return 500;
  }

  int get _nights {
    final diff = _checkOut.difference(_checkIn).inDays;
    return diff < 1 ? 1 : diff;
  }

  int get _totalPrice => _unitPrice * _nights;

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static int? _parseInt(String s) {
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  bool get _isLoggedIn => AuthController.instance.isLoggedIn;

  // ---- اختيار التواريخ والأوقات ----
  Future<void> _pickCheckIn() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn,
      firstDate: _dayOnly(DateTime.now()).add(const Duration(days: 1)),
      lastDate: _dayOnly(DateTime.now()).add(const Duration(days: 365)),
      helpText: 'تاريخ الوصول',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );
    if (picked == null) return;
    setState(() {
      _checkIn = _dayOnly(picked);
      if (!_checkOut.isAfter(_checkIn)) {
        _checkOut = _checkIn.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _pickCheckOut() async {
    final firstDate = _checkIn.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOut.isAfter(firstDate) ? _checkOut : firstDate,
      firstDate: firstDate,
      lastDate: _dayOnly(DateTime.now()).add(const Duration(days: 365)),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: Theme(
          data: Theme.of(context).copyWith(primaryColor: AppColors.primary),
          child: child!,
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _checkOut = _dayOnly(picked));
  }

  Future<void> _pickTime(bool isCheckIn) async {
    final initial = isCheckIn ? _checkInTime : _checkOutTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
      helpText: isCheckIn ? 'وقت الوصول' : 'وقت المغادرة',
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkInTime = picked;
      } else {
        _checkOutTime = picked;
      }
    });
  }

  String get _timeLabelCheckIn => _timeLabel(_checkInTime);
  String get _timeLabelCheckOut => _timeLabel(_checkOutTime);

  static String _timeLabel(TimeOfDay t) {
    final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final suffix = t.hour < 12 ? 'صباحاً' : 'مساءً';
    return '$hour12:${t.minute.toString().padLeft(2, '0')} $suffix';
  }

  // ---- الإرسال ----
  Future<void> _submit() async {
    if (_controller.submitting.value) return;
    if (!_isLoggedIn) {
      Get.snackbar('تسجيل الدخول', 'يجب تسجيل الدخول أولاً لحجز العقار',
          snackPosition: SnackPosition.TOP, backgroundColor: AppColors.black);
      Get.toNamed(AppRoutes.login);
      return;
    }
    final propertyId = _property?.id;
    if (propertyId == null) {
      Get.snackbar('خطأ', 'تعذر معرفة العقار المراد حجزه',
          backgroundColor: const Color(0xFFC62828));
      return;
    }
    final ok = await _controller.submit(CreateBookingRequest(
      propertyId: propertyId,
      checkInDate: _checkIn,
      checkOutDate: _checkOut,
      checkInTime: '${_two(_checkInTime.hour)}:${_two(_checkInTime.minute)}',
      checkOutTime: '${_two(_checkOutTime.hour)}:${_two(_checkOutTime.minute)}',
      nights: _nights,
      guests: _guests,
      totalPrice: _totalPrice,
      notes: _notesController.text,
    ));
    if (!mounted) return;
    if (ok) {
      final booking = _controller.created.value;
      Get.snackbar('تم الحجز', 'تم إنشاء الحجز بنجاح',
          backgroundColor: const Color(0xFF2E7D32));
      if (booking?.id != null) {
        Get.toNamed(AppRoutes.bookingDetail, arguments: booking!.id);
      } else {
        Get.back();
      }
    } else {
      Get.snackbar('تعذر الحجز',
          _controller.errorMessage.value ?? 'حدث خطأ ما، حاول مرة أخرى',
          backgroundColor: const Color(0xFFC62828));
    }
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  static InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: _outline(AppColors.fieldBorder),
        enabledBorder: _outline(AppColors.fieldBorder),
        focusedBorder: _outline(AppColors.primary),
      );

  static OutlineInputBorder _outline(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    final prop = _property;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _Header(title: 'تأكيد الحجز'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  if (prop != null) _PropertySummary(prop: prop, unitPrice: _unitPrice),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'مدة الإيجار',
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 330),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _DateSelector(
                                  label: 'تاريخ الوصول',
                                  value: _fmtDate(_checkIn),
                                  onTap: _pickCheckIn,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DateSelector(
                                  label: 'تاريخ المغادرة',
                                  value: _fmtDate(_checkOut),
                                  onTap: _pickCheckOut,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 330),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _TimeSelector(
                                  label: 'وقت الوصول',
                                  value: _timeLabelCheckIn,
                                  onTap: () => _pickTime(true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _TimeSelector(
                                  label: 'وقت المغادرة',
                                  value: _timeLabelCheckOut,
                                  onTap: () => _pickTime(false),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _GuestsSelector(
                        guests: _guests,
                        onChanged: (v) => setState(() => _guests = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'ملاحظات',
                    children: [
                      TextField(
                        controller: _notesController,
                        minLines: 2,
                        maxLines: 4,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14, color: AppColors.black),
                        decoration: _inputDecoration('أي ملاحظات لصاحب العقار (اختياري)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _CostCard(
                    unitPrice: _unitPrice,
                    nights: _nights,
                    total: _totalPrice,
                  ),
                  const SizedBox(height: 16),
                  _SummaryInfo(
                    nights: _nights,
                    guests: _guests,
                    total: _totalPrice,
                  ),
                ],
              ),
            ),
          ),
          _SubmitBar(
            submitting: _controller.submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(Icons.arrow_forward, color: AppColors.black, size: 24),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}

class _PropertySummary extends StatelessWidget {
  final Property prop;
  final int unitPrice;
  const _PropertySummary({required this.prop, required this.unitPrice});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: PropertyImage(
            imageUrl: prop.imageUrl,
            fallbackAsset: prop.image,
            height: 170,
            width: double.infinity,
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Text(prop.title,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.black)),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(prop.location,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              const SizedBox(width: 4),
              const Icon(Icons.location_on, size: 14, color: AppColors.primary),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text('$unitPrice ريال / ليلة',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.black)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  final String label;
  final String value;
  const _FieldBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.grey)),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black)),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label, value;
  final VoidCallback onTap;
  const _DateSelector({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _FieldBox(
        label: label,
        value: value,
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label, value;
  final VoidCallback onTap;
  const _TimeSelector({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _FieldBox(
        label: label,
        value: value,
      ),
    );
  }
}

class _GuestsSelector extends StatelessWidget {
  final int guests;
  final ValueChanged<int> onChanged;
  const _GuestsSelector({required this.guests, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          const Text('عدد الضيوف', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.black)),
          const Spacer(),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.grey),
            onPressed: guests > 1 ? () => onChanged(guests - 1) : null,
          ),
          Text('$guests', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: guests < 10 ? () => onChanged(guests + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  final int unitPrice, nights, total;
  const _CostCard({required this.unitPrice, required this.nights, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          _CostRow(label: 'السعر لكل ليلة ($nights ليال)', value: '$unitPrice ريال'),
          const Divider(height: 20, color: Color(0xFFF2F4F7)),
          Row(
            children: [
              const Text('المجموع الكلي',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
              const Spacer(),
              Text('$total ريال',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label, value;
  const _CostRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey))),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black)),
      ],
    );
  }
}

class _SummaryInfo extends StatelessWidget {
  final int nights, guests;
  final int total;
  const _SummaryInfo({required this.nights, required this.guests, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text('$nights ليال × $guests ضيوف — الإجمالي $total ريال',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  final RxBool submitting;
  final VoidCallback onPressed;
  const _SubmitBar({required this.submitting, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: submitting.value ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 6,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
            ),
            child: Obx(() {
              return submitting.value
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white),
                    )
                  : const Text('تأكيد الحجز', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
            }),
          ),
        ),
      ),
    );
  }
}