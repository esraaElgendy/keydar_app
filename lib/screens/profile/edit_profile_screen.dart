import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Stack(
                children: [
                  Center(
                    child: Text('الملف الشخصي',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black)),
                  ),
                  Positioned(
                    left: 0,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.arrow_forward, color: AppColors.black, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Stack(
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.fieldBorder),
                          child: const Icon(Icons.person, size: 50, color: AppColors.grey),
                        ),
                        Positioned(bottom: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                            child: const Icon(Icons.edit, size: 16, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('تغيير الصورة الشخصية',
                      style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),
                    _Field(label: 'الاسم الكامل', icon: Icons.person_outline, value: 'أحمد محمد'),
                    const SizedBox(height: 16),
                    _Field(label: 'البريد الإلكتروني', icon: Icons.email_outlined, value: 'ahmed.m@example.com'),
                    const SizedBox(height: 16),
                    _Field(label: 'رقم الجوال', icon: Icons.phone_outlined, value: '+966 55 123 4567'),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 6,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: const Text('حفظ التغييرات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
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

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  const _Field({required this.label, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.grey),
              const SizedBox(width: 10),
              Text(value, style: const TextStyle(fontSize: 14, color: AppColors.black)),
            ],
          ),
        ),
      ],
    );
  }
}
