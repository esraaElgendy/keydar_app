import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _app = true;
  bool _email = true;
  bool _sms = false;
  bool _offers = true;

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
                      child: Text('الإشعارات',
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
                    _SwitchTile(
                      title: 'إشعارات التطبيق',
                      subtitle: 'تنبيهات الحجوزات والعروض',
                      value: _app,
                      onChanged: (v) => setState(() => _app = v),
                    ),
                    const SizedBox(height: 12),
                    _SwitchTile(
                      title: 'البريد الإلكتروني',
                      subtitle: 'ملخص أسبوعي وفواتير',
                      value: _email,
                      onChanged: (v) => setState(() => _email = v),
                    ),
                    const SizedBox(height: 12),
                    _SwitchTile(
                      title: 'رسائل نصية (SMS)',
                      subtitle: 'تأكيد الحجوزات فقط',
                      value: _sms,
                      onChanged: (v) => setState(() => _sms = v),
                    ),
                    const SizedBox(height: 12),
                    _SwitchTile(
                      title: 'العروض الخاصة',
                      subtitle: 'خصومات وتحديثات حصرية',
                      value: _offers,
                      onChanged: (v) => setState(() => _offers = v),
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

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.grey)),
            ],
          ),
          const Spacer(),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
