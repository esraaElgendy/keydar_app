import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _ProfileHeader(),
                    const SizedBox(height: 24),
                    _Section(title: 'الحساب', children: [
                      _OptionTile(icon: Icons.person_outline, label: 'المعلومات الشخصية', onTap: () => Get.toNamed(AppRoutes.editProfile)),
                      _OptionTile(icon: Icons.credit_card_outlined, label: 'طرق الدفع'),
                      _OptionTile(icon: Icons.notifications_outlined, label: 'الإشعارات', onTap: () => Get.toNamed(AppRoutes.notifications)),
                    ]),
                    const SizedBox(height: 20),
                    _Section(title: 'التطبيق', children: [
                      _OptionTile(icon: Icons.language, label: 'اللغة', trailing: 'العربية'),
                      _OptionTile(icon: Icons.dark_mode_outlined, label: 'المظهر', trailing: 'فاتح'),
                      _OptionTile(icon: Icons.shield_outlined, label: 'الخصوصية والأمان'),
                    ]),
                    const SizedBox(height: 20),
                    _Section(title: 'الدعم', children: [
                      _OptionTile(icon: Icons.help_outline, label: 'مركز المساعدة'),
                      _OptionTile(icon: Icons.chat_bubble_outline, label: 'تواصل معنا', onTap: () => Get.toNamed(AppRoutes.contactUs)),
                    ]),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('تسجيل الخروج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, color: Colors.red, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            AppBottomNav(currentIndex: 4, onTap: (i) {
              switch (i) {
                case 0: Get.offNamed(AppRoutes.home);
                case 1: Get.offNamed(AppRoutes.explore);
                case 2: Get.offNamed(AppRoutes.favorites);
                case 3: Get.offNamed(AppRoutes.myBookings);
                case 4: break;
              }
            }),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.fieldBorder),
              child: const Icon(Icons.person, size: 40, color: AppColors.grey),
            ),
            Positioned(bottom: 0, left: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                child: const Icon(Icons.edit, size: 12, color: AppColors.white),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('أحمد محمد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
              const SizedBox(height: 4),
              Text('ahmed.m@example.com', style: TextStyle(fontSize: 14, color: AppColors.grey)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('عضو مميز', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(title, style: TextStyle(fontSize: 14, color: AppColors.grey.withValues(alpha: 0.6))),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children.asMap().entries.map((e) {
              final isLast = e.key == children.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast) Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: AppColors.fieldBorder),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  const _OptionTile({required this.icon, required this.label, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.grey),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 14, color: AppColors.black)),
            const Spacer(),
            if (trailing != null) ...[
              Text(trailing!, style: TextStyle(fontSize: 13, color: AppColors.grey)),
              const SizedBox(width: 8),
            ],
            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
