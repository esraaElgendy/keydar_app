import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/app_controller.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late AppController ctrl;
  int _selectedType = 0;
  int _selectedPayment = 0;
  RangeValues _priceRange = const RangeValues(1000, 500000);
  int _bedrooms = 2;
  int _bathrooms = 2;
  final Set<int> _selectedAmenities = {};

  final _types = ['شقة', 'مكتب', 'أرض', 'استوديو', 'فيلا'];
  final _payments = ['سنوي', 'شهري', 'يومي'];
  final _amenities = [
    ('واي فاي', Icons.wifi),
    ('مسبح', Icons.pool),
    ('تكييف', Icons.ac_unit),
    ('موقف سيارات', Icons.local_parking),
    ('نادي رياضي', Icons.fitness_center),
    ('حراسة', Icons.security),
  ];

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<AppController>();
    _selectedType = ctrl.filterType.value;
    _selectedPayment = ctrl.filterPayment.value;
    _priceRange = RangeValues(ctrl.filterPriceMin.value, ctrl.filterPriceMax.value);
    _bedrooms = ctrl.filterBedrooms.value;
    _bathrooms = ctrl.filterBathrooms.value;
    _selectedAmenities.addAll(ctrl.filterAmenities);
  }

  void _apply() {
    ctrl.applyFilters(
      type: _selectedType,
      payment: _selectedPayment,
      priceMin: _priceRange.start,
      priceMax: _priceRange.end,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      amenities: Set.from(_selectedAmenities),
    );
    Get.back();
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('بحث متقدم', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black)),
                      SizedBox(height: 2),
                      Text('خصص بحثك بدقة', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, color: AppColors.black, size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _SectionTitle('الموقع'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _LocationDropdown(icon: Icons.flag_outlined, text: 'السعودية'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _LocationDropdown(icon: Icons.location_on, text: 'الرياض'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle('نوع العقار'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _types.asMap().entries.map((e) => GestureDetector(
                        onTap: () => setState(() => _selectedType = e.key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: e.key == _selectedType ? AppColors.primary : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: e.key == _selectedType ? null : Border.all(color: AppColors.fieldBorder),
                          ),
                          child: Text(e.value, style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: e.key == _selectedType ? AppColors.white : AppColors.black,
                          )),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle('نطاق السعر'),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 500000,
                      divisions: 10,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.fieldBorder,
                      labels: RangeLabels(_formatPrice(_priceRange.start), _formatPrice(_priceRange.end)),
                      onChanged: (v) => setState(() => _priceRange = v),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(_formatPrice(_priceRange.start), style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.6))),
                        const Spacer(),
                        Text(_formatPrice(_priceRange.end), style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.6))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _payments.asMap().entries.map((e) => GestureDetector(
                        onTap: () => setState(() => _selectedPayment = e.key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: e.key == _selectedPayment ? AppColors.primary : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: e.key == _selectedPayment ? null : Border.all(color: AppColors.fieldBorder),
                          ),
                          child: Text(e.value, style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: e.key == _selectedPayment ? AppColors.white : AppColors.black,
                          )),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle('المواصفات'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.fieldBorder),
                      ),
                      child: Column(
                        children: [
                          _CounterRow(label: 'غرف النوم', icon: Icons.bed_outlined, value: _bedrooms, onChanged: (v) => setState(() => _bedrooms = v)),
                          const Divider(height: 24),
                          _CounterRow(label: 'دورات المياه', icon: Icons.bathtub_outlined, value: _bathrooms, onChanged: (v) => setState(() => _bathrooms = v)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle('وسائل الراحة'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _amenities.asMap().entries.map((e) => GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedAmenities.contains(e.key)) {
                              _selectedAmenities.remove(e.key);
                            } else {
                              _selectedAmenities.add(e.key);
                            }
                          });
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 48) / 2,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _selectedAmenities.contains(e.key) ? AppColors.primary : AppColors.fieldBorder),
                          ),
                          child: Row(
                            children: [
                              Text(e.value.$1, style: const TextStyle(fontSize: 14, color: AppColors.black)),
                              const Spacer(),
                              Icon(e.value.$2, size: 18, color: AppColors.grey.withValues(alpha: 0.6)),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 6,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  child: const Text('تطبيق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double v) {
    if (v >= 1000) return '${(v / 1000).toInt()} ألف';
    return v.toInt().toString();
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black));
  }
}

class _LocationDropdown extends StatelessWidget {
  final IconData icon;
  final String text;
  const _LocationDropdown({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.black)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.grey, size: 18),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;
  const _CounterRow({required this.label, required this.icon, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.black)),
        const SizedBox(width: 4),
        Icon(icon, size: 16, color: AppColors.grey.withValues(alpha: 0.6)),
        const Spacer(),
        Row(
          children: [
            GestureDetector(onTap: () => onChanged(value > 0 ? value - 1 : 0), child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.fieldBorder)),
              child: const Icon(Icons.remove, size: 18, color: AppColors.grey),
            )),
            const SizedBox(width: 12),
            Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => onChanged(value + 1), child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.fieldBorder)),
              child: const Icon(Icons.add, size: 18, color: AppColors.primary),
            )),
          ],
        ),
      ],
    );
  }
}
