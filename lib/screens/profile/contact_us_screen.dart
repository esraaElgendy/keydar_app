import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

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
                      child: Text('تواصل بنا',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black)),
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.phone, color: AppColors.primary, size: 22),
                                ),
                                const SizedBox(height: 6),
                                const Text('اتصل بنا', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.chat, color: Color(0xFF25D366), size: 22),
                                ),
                                const SizedBox(height: 6),
                                const Text('واتساب', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text('أرسل لنا رسالة',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                    ),
                    const SizedBox(height: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6, left: 4),
                          child: Text('عنوان الرسالة',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const TextField(
                            textDirection: TextDirection.rtl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'اكتب عنوان الرسالة',
                              hintTextDirection: TextDirection.rtl,
                              hintStyle: TextStyle(fontSize: 14, color: AppColors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6, left: 4),
                          child: Text('نص الرسالة',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const TextField(
                            textDirection: TextDirection.rtl,
                            maxLines: 5,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'اكتب رسالتك هنا...',
                              hintTextDirection: TextDirection.rtl,
                              hintStyle: TextStyle(fontSize: 14, color: AppColors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 6,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: const Text('إرسال الرسالة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ساعات العمل: الأحد - الخميس\n9:00 صباحاً - 6:00 مساءً',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.grey.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
