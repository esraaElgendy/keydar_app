import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/property_repository.dart';
import '../../models/property.dart';

/// شاشة تعديل عقار موجود — تُعرض بيانات العقار الحالية في حقول قابلة للتعديل
/// وتحفظ كل الحقول عبر PUT كامل يحافظ على المرافق والمواصفات.
class EditPropertyScreen extends StatefulWidget {
  final Property property;
  const EditPropertyScreen({super.key, required this.property});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _dailyCtrl;
  late final TextEditingController _monthlyCtrl;
  late final TextEditingController _yearlyCtrl;

  late String _type;
  late String _city;
  late String _furnishing;
  late String _period;
  int _beds = 1;
  int _baths = 1;
  int _guests = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _titleCtrl = TextEditingController(text: p.title);
    _descCtrl = TextEditingController(text: p.description);
    _locationCtrl = TextEditingController(text: p.location);
    _areaCtrl = TextEditingController(text: p.area == 0 ? '' : p.area.toStringAsFixed(0));
    _dailyCtrl = TextEditingController(text: _numText(p.prices?['daily']));
    _monthlyCtrl = TextEditingController(text: _numText(p.prices?['monthly']));
    _yearlyCtrl = TextEditingController(text: _numText(p.prices?['yearly']));
    _type = _typeLabel(p.type);
    _city = _cityLabel(p.city);
    _furnishing = _furnishingLabel(p.furnishing);
    _period = _periodLabel(p.period);
    _beds = p.bedrooms > 0 ? p.bedrooms : 1;
    _baths = p.bathrooms > 0 ? p.bathrooms : 1;
    _guests = p.guests > 0 ? p.guests : 1;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _areaCtrl.dispose();
    _dailyCtrl.dispose();
    _monthlyCtrl.dispose();
    _yearlyCtrl.dispose();
    super.dispose();
  }

  static String _numText(num? v) {
    if (v == null || v == 0) return '';
    final asInt = v.toInt();
    return asInt.toString();
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      Get.snackbar('معلومات ناقصة', 'أدخل اسم العقار ووصفه قبل الحفظ',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: AppColors.white);
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = await PropertyRepository().updateOwnerProperty(
        id: widget.property.id!,
        current: widget.property,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        city: _cityMap[_city] ?? widget.property.city ?? 'Riyadh',
        propertyType: _typeMap[_type] ?? widget.property.type,
        furnishing: _furnishingMap[_furnishing] ?? widget.property.furnishing,
        period: _period,
        area: num.tryParse(_areaCtrl.text) ?? widget.property.area,
        prices: {
          'daily': num.tryParse(_dailyCtrl.text) ?? widget.property.prices?['daily'] ?? 0,
          'monthly': num.tryParse(_monthlyCtrl.text) ?? widget.property.prices?['monthly'] ?? 0,
          'yearly': num.tryParse(_yearlyCtrl.text) ?? widget.property.prices?['yearly'] ?? 0,
        },
        beds: _beds,
        baths: _baths,
        guests: _guests,
      );
      Get.find<AppController>().replaceOwnerProperty(updated);
      if (!mounted) return;
      Get.snackbar('تم الحفظ', 'تم تحديث بيانات العقار بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: AppColors.white);
      Get.back();
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('فشل الحفظ', 'تعذر تحديث العقار، حاول مرة أخرى.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFC62828),
          colorText: AppColors.white);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fieldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('تعديل العقار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        leading: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('اسم العقار'),
                  const SizedBox(height: 6),
                  _Input(controller: _titleCtrl, hint: 'مثال: فيلا فاخرة بموقع مميز'),
                  const SizedBox(height: 16),
                  const _FieldLabel('وصف العقار'),
                  const SizedBox(height: 6),
                  _Input(controller: _descCtrl, hint: 'اكتب وصفاً تفصيلياً...', maxLines: 4),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _Dropdown(label: 'نوع العقار', value: _type, items: _typeMap.keys.toList(), onChanged: (v) => setState(() => _type = v))),
                      const SizedBox(width: 12),
                      Expanded(child: _Dropdown(label: 'المدينة', value: _city, items: _cityMap.keys.toList(), onChanged: (v) => setState(() => _city = v))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _Dropdown(label: 'التأثيث', value: _furnishing, items: _furnishingMap.keys.toList(), onChanged: (v) => setState(() => _furnishing = v))),
                      const SizedBox(width: 12),
                      Expanded(child: _Dropdown(label: 'فترة الإيجار', value: _period, items: _periodMap.keys.toList(), onChanged: (v) => setState(() => _period = v))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _FieldLabel('الموقع / العنوان'),
                  const SizedBox(height: 6),
                  _Input(controller: _locationCtrl, hint: 'حي النرجس، الرياض'),
                  const SizedBox(height: 16),
                  const _FieldLabel('المساحة (م²)'),
                  const SizedBox(height: 6),
                  _Input(controller: _areaCtrl, hint: '120', number: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('الغرف والضيوف'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _CountStepper(label: 'الغرف', icon: Icons.bed, value: _beds, onChanged: (v) => setState(() => _beds = v))),
                      const SizedBox(width: 10),
                      Expanded(child: _CountStepper(label: 'الحمامات', icon: Icons.bathroom, value: _baths, onChanged: (v) => setState(() => _baths = v))),
                      const SizedBox(width: 10),
                      Expanded(child: _CountStepper(label: 'الضيوف', icon: Icons.people, value: _guests, onChanged: (v) => setState(() => _guests = v))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('الأسعار (ر.س)'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _PriceInput(label: 'يومي', controller: _dailyCtrl)),
                      const SizedBox(width: 10),
                      Expanded(child: _PriceInput(label: 'شهري', controller: _monthlyCtrl)),
                      const SizedBox(width: 10),
                      Expanded(child: _PriceInput(label: 'سنوي', controller: _yearlyCtrl)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
                    : const Text('حفظ التعديلات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'المرافق تُعدَّل من صفحة تفاصيل العقار',
                style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.8)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: child,
      );

  static const Map<String, String> _typeMap = {
    'فيلا': 'villa', 'شقة': 'apartment', 'مكتب': 'office', 'دوبلكس': 'duplex',
    'استوديو': 'studio', 'بنتهاوس': 'penthouse', 'تجاري': 'commercial', 'مزرعة': 'farm',
  };
  static const Map<String, String> _cityMap = {
    'الرياض': 'Riyadh', 'جدة': 'Jeddah', 'الدمام': 'Dammam', 'الخبر': 'Khobar',
    'مكة': 'Makkah', 'المدينة': 'Madinah', 'أبها': 'Abha', 'تبوك': 'Tabuk',
  };
  static const Map<String, String> _furnishingMap = {
    'مفروش': 'furnished', 'غير مفروش': 'unfurnished', 'شبه مفروش': 'semi-furnished',
  };
  static const Map<String, String> _periodMap = {
    'يومياً': 'daily', 'شهرياً': 'monthly', 'سنوياً': 'yearly',
  };

  static String _typeLabel(String t) => _typeMap.entries
      .firstWhere((e) => e.value == t, orElse: () => const MapEntry('شقة', 'apartment'))
      .key;
  static String _cityLabel(String? c) => _cityMap.entries
      .firstWhere((e) => e.value == c, orElse: () => const MapEntry('الرياض', 'Riyadh'))
      .key;
  static String _furnishingLabel(String? f) => _furnishingMap.entries
      .firstWhere((e) => e.value == f, orElse: () => const MapEntry('مفروش', 'furnished'))
      .key;
  static String _periodLabel(String p) {
    switch (p) {
      case 'يومياً':
      case 'daily':
        return 'يومياً';
      case 'سنوياً':
      case 'yearly':
        return 'سنوياً';
      default:
        return 'شهرياً';
    }
  }
}

// ───── Widgets ─────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText));
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool number;

  const _Input({required this.controller, required this.hint, this.maxLines = 1, this.number = false});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
          inputFormatters: number ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))] : null,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontSize: 14, color: AppColors.darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      );
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _Dropdown({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            underline: const SizedBox.shrink(),
            dropdownColor: AppColors.white,
            style: const TextStyle(fontSize: 14, color: AppColors.darkText),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
            items: items.map((it) => DropdownMenuItem(value: it, child: Text(it, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

class _CountStepper extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;
  const _CountStepper({required this.label, required this.icon, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: AppColors.grey),
              const SizedBox(width: 3),
              Flexible(child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepBtn(Icons.remove, () => onChanged((value - 1).clamp(1, 99))),
                SizedBox(width: 34, child: Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText), textAlign: TextAlign.center)),
                _stepBtn(Icons.add, () => onChanged((value + 1).clamp(1, 99))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 26, height: 26,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      );
}

class _PriceInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _PriceInput({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))],
              style: const TextStyle(fontSize: 14, color: AppColors.darkText),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(fontSize: 14, color: AppColors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
          ),
        ],
      );
}