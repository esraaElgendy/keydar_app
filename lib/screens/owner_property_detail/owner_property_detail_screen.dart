import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/routes/app_routes.dart';
import '../../models/property.dart';

class OwnerPropertyDetailScreen extends StatefulWidget {
  final Property property;
  const OwnerPropertyDetailScreen({super.key, required this.property});

  @override
  State<OwnerPropertyDetailScreen> createState() => _OwnerPropertyDetailScreenState();
}

class _OwnerPropertyDetailScreenState extends State<OwnerPropertyDetailScreen> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward, color: AppColors.black),
            onPressed: () => Get.back(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: IconButton(
              icon: const Icon(Icons.menu, color: AppColors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Segmented tab bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(child: _Segment(label: 'الكل', isActive: _selectedSegment == 0, onTap: () => setState(() => _selectedSegment = 0))),
                    Expanded(child: _Segment(label: 'شقق (5)', isActive: _selectedSegment == 1, onTap: () => setState(() => _selectedSegment = 1))),
                    Expanded(child: _Segment(label: 'مكاتب (2)', isActive: _selectedSegment == 2, onTap: () => setState(() => _selectedSegment = 2))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Main property card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Stack(
                        children: [
                          Image.asset(
                            AppAssets.building,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 180,
                              color: AppColors.darkBlue,
                              child: const Icon(Icons.business, color: AppColors.white, size: 60),
                            ),
                          ),
                          Positioned(
                            top: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('نشط', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Edit row
                          Row(
                            children: [
                              const Icon(Icons.edit, color: AppColors.grey, size: 16),
                              const SizedBox(width: 4),
                              const Text('تعديل', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('29 أكتوبر - 31 أكتوبر', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Title and location
                          Text(widget.property.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
                          const SizedBox(height: 4),
                          Text(widget.property.location, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                          const SizedBox(height: 14),
                          // Price row
                          Row(
                            children: [
                              const Text('/ سنة', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                              const SizedBox(width: 4),
                              Text('${widget.property.price} SAR', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                              const Spacer(),
                              Text('/ شهرياً', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                            ],
                          ),
                          const Divider(height: 24, color: AppColors.fieldBorder),
                          // Total bar
                          Row(
                            children: [
                              const Text('المجموع الكلي', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                              const Spacer(),
                              const Text('رسوم الخدمات', style: TextStyle(fontSize: 11, color: Color(0xFFFF9800), fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              const Text('2,300,000 ريال', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                            ],
                          ),
                          const Divider(height: 24, color: AppColors.fieldBorder),
                          // Specs row
                          Row(
                            children: [
                              _SpecItem2(icon: Icons.bed, text: '${widget.property.bedrooms} غرف'),
                              const SizedBox(width: 16),
                              _SpecItem2(icon: Icons.bathroom, text: '${widget.property.bathrooms} حمام'),
                              const SizedBox(width: 16),
                              _SpecItem2(icon: Icons.square_foot, text: '${widget.property.area} م²'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Additional info section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('معلومات إضافية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _InfoChip(label: 'المعرف', value: '1258')),
                        const SizedBox(width: 10),
                        Expanded(child: _InfoChip(label: 'رقم العقار', value: '1258')),
                        const SizedBox(width: 10),
                        Expanded(child: _InfoChip(label: 'تاريخ الإضافة', value: '2024/06/20')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Spacer(),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 80) / 3,
                          child: _InfoChip(label: 'عدد المشاهدات', value: '256'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - 60,
        height: 54,
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.addProperty),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 6,
          icon: const Icon(Icons.add, color: AppColors.white, size: 22),
          label: const Text('إضافة عقار جديد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _Segment({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.white : AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecItem2 extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SpecItem2({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.darkText, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        ],
      ),
    );
  }
}
