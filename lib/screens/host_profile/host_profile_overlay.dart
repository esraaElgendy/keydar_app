import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';

class HostProfileOverlay extends StatelessWidget {
  const HostProfileOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('لوحة التحكم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white)),
        leading: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit, color: AppColors.primary, size: 18),
                      const SizedBox(width: 4),
                      const Text('بيانات التعديل', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text('29 أكتوبر - 31 أكتوبر', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('الرسائل', style: TextStyle(fontSize: 14, color: AppColors.grey)),
                  const SizedBox(height: 4),
                  const Text('طلبات جديدة', style: TextStyle(fontSize: 14, color: AppColors.grey)),
                  const SizedBox(height: 20),
                  // Property image card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.asset(AppAssets.building, height: 160, width: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(height: 160, color: AppColors.darkBlue,
                            child: const Icon(Icons.business, color: AppColors.white, size: 50))),
                        Positioned(top: 12, right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('مؤكد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                                SizedBox(width: 4),
                                Icon(Icons.check, size: 12, color: Color(0xFF2E7D32)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('شقة فاخرة في الرياض', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Text('3,200 SAR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                      SizedBox(width: 4),
                      Text('/ شهرياً', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.fieldBorder),
                  Row(
                    children: [
                      const Icon(Icons.edit, color: AppColors.grey, size: 14),
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
                  const SizedBox(height: 8),
                  const Text('شقة فاخرة في الرياض', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
                  const SizedBox(height: 4),
                  const Text('الرياض، العليا', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Text('/ سنة', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                      SizedBox(width: 4),
                      Text('3,200 SAR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                      Spacer(),
                      Text('/ شهرياً', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.fieldBorder),
                  const Row(
                    children: [
                      Text('المجموع الكلي', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                      Spacer(),
                      Text('رسوم الخدمات', style: TextStyle(fontSize: 11, color: Color(0xFFFF9800), fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Text('2,300,000 ريال', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.fieldBorder),
                  const Row(
                    children: [
                      _Spec(icon: Icons.bed, text: '4 غرف'),
                      SizedBox(width: 16),
                      _Spec(icon: Icons.bathroom, text: '2 حمام'),
                      SizedBox(width: 16),
                      _Spec(icon: Icons.square_foot, text: '120 م²'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'ساعات العمل: الأحد - الخميس\n9:00 صباحاً - 6:00 مساءً',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('حفظ التغييرات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Spec({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.black, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
