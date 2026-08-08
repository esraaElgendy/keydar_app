import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/tenant.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _HeroCard(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _StatisticsCard(),
                          const SizedBox(height: 16),
                          _TenantsPreviewCard(),
                          const SizedBox(height: 16),
                          _DocumentsCard(),
                          const SizedBox(height: 16),
                          _SettingsCard(),
                          const SizedBox(height: 24),
                          _LogoutButton(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.grey,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: 3,
              onTap: (i) {
                if (i == 0) {
                  Get.offNamed(AppRoutes.ownerDashboard);
                } else if (i == 1) {
                  Get.offNamed(AppRoutes.myProperties);
                } else if (i == 2) {
                  Get.offNamed(AppRoutes.myBookings);
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
                BottomNavigationBarItem(icon: Icon(Icons.business), label: 'عقاراتي'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'حجوزاتي'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47C9), Color(0xFF1565C0)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
            ),
            child: const Icon(Icons.person, size: 44, color: Colors.white),
          ),
          const SizedBox(height: 14),
          const Text('محمد أحمد', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Verified Owner', style: TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(width: 6),
              Icon(Icons.verified, size: 16, color: Colors.amber.shade300),
            ],
          ),
          const SizedBox(height: 6),
          Text('owner@example.com', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 2),
          Text('+966 50 123 4567', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroStat(value: '18', label: 'عقار'),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.2)),
              _HeroStat(value: '26', label: 'وحدة'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value, label;
  const _HeroStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
        ],
      ),
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('إحصائياتي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF0D47C9).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.bar_chart_rounded, size: 16, color: Color(0xFF0D47C9)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatBox(label: 'الحجوزات', value: '24', icon: Icons.calendar_today, color: const Color(0xFF0D47C9)),
              const SizedBox(width: 8),
              _StatBox(label: 'الإيرادات', value: '48k', icon: Icons.trending_up, color: const Color(0xFF2E7D32)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatBox(label: 'مؤجرة', value: '12', icon: Icons.check_circle, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 10),
              _StatBox(label: 'متاحة', value: '14', icon: Icons.home_work, color: const Color(0xFFF57C00)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Flexible(child: Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7)))),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class _TenantsPreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF0D47C9).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.people_outline, size: 16, color: Color(0xFF0D47C9)),
              ),
              const SizedBox(width: 8),
              const Text('المستأجرون', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.tenantsList),
                child: const Row(
                  children: [
                    Text('>', style: TextStyle(fontSize: 16, color: AppColors.grey)),
                    SizedBox(width: 8),
                    Text('عرض الكل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0D47C9))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tenants.take(3).map((t) => _TenantPreviewTile(tenant: t)),
        ],
      ),
    );
  }
}

class _TenantPreviewTile extends StatelessWidget {
  final Tenant tenant;
  const _TenantPreviewTile({required this.tenant});

  @override
  Widget build(BuildContext context) {
    final statusColor = tenant.contractStatus == 'نشط'
        ? const Color(0xFF2E7D32)
        : tenant.contractStatus == 'منتهي'
            ? AppColors.grey
            : const Color(0xFFE65100);
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.tenantDetail, arguments: tenant),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFF0D47C9).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Text(tenant.name[0], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D47C9))),
              ),
            ),
            const SizedBox(width: 10),
            Text(tenant.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A24))),
            const SizedBox(width: 10),
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
            ),
            const SizedBox(width: 6),
            Text(tenant.contractStatus, style: TextStyle(fontSize: 12, color: statusColor)),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF0D47C9).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.description_outlined, size: 16, color: Color(0xFF0D47C9)),
              ),
              const SizedBox(width: 8),
              const Text('المستندات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
              const Spacer(),
              const Text('>', style: TextStyle(fontSize: 16, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 14),
          _DocTile(label: 'سند الملكية', uploaded: true),
          const SizedBox(height: 8),
          _DocTile(label: 'الهوية الوطنية', uploaded: true),
          const SizedBox(height: 8),
          _DocTile(label: 'الحساب البنكي', uploaded: false),
        ],
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  final String label;
  final bool uploaded;
  const _DocTile({required this.label, required this.uploaded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: uploaded ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A24))),
          const Spacer(),
          Text(uploaded ? 'مرفوع ✓' : 'غير مرفوع', style: TextStyle(fontSize: 12, color: uploaded ? const Color(0xFF2E7D32) : const Color(0xFFE65100))),
          const SizedBox(width: 8),
          Icon(uploaded ? Icons.check_circle : Icons.warning_amber_rounded, size: 16,
               color: uploaded ? const Color(0xFF2E7D32) : const Color(0xFFE65100)),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _SettingToggle(icon: Icons.notifications_outlined, title: 'الإشعارات', subtitle: 'Push notifications'),
          const Divider(height: 20, color: Color(0xFFF2F4F7)),
          _SettingToggle(icon: Icons.sms_outlined, title: 'الرسائل النصية', subtitle: 'SMS'),
          const Divider(height: 20, color: Color(0xFFF2F4F7)),
          _SettingToggle(icon: Icons.email_outlined, title: 'البريد الإلكتروني', subtitle: 'Email'),
          const Divider(height: 20, color: Color(0xFFF2F4F7)),
          _SettingRow(icon: Icons.language, title: 'اللغة', trailing: 'العربية', onTap: () {}),
          const Divider(height: 20, color: Color(0xFFF2F4F7)),
          _SettingRow(icon: Icons.lock_outline, title: 'تغيير كلمة المرور', onTap: () {}),
          const Divider(height: 20, color: Color(0xFFF2F4F7)),
          _SettingRow(icon: Icons.fingerprint, title: 'البصمة', trailing: '' , onTap: () {}),
          const Divider(height: 20, color: Color(0xFFF2F4F7)),
          _SettingRow(icon: Icons.help_outline, title: 'مركز المساعدة', onTap: () {}),
        ],
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _SettingToggle({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grey),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A24))),
        const Spacer(),
        Switch(value: true, onChanged: (_) {}, activeThumbColor: const Color(0xFF0D47C9), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  const _SettingRow({required this.icon, required this.title, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.grey),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A24))),
          const Spacer(),
          if (trailing != null) ...[
            Text(trailing!, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A24))),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('تسجيل الخروج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
            SizedBox(width: 8),
            Icon(Icons.logout, size: 18, color: Color(0xFFC62828)),
          ],
        ),
      ),
    );
  }
}
