import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/tenant.dart';

class TenantDetailScreen extends StatelessWidget {
  const TenantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Get.arguments as Tenant;
    final statusColor = t.contractStatus == 'نشط'
        ? const Color(0xFF2E7D32)
        : t.contractStatus == 'منتهي'
            ? AppColors.grey
            : const Color(0xFFE65100);
    final statusBg = t.contractStatus == 'نشط'
        ? const Color(0xFFE8F5E9)
        : t.contractStatus == 'منتهي'
            ? const Color(0xFFF5F5F5)
            : const Color(0xFFFFF3E0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A24)),
            onPressed: () => Get.back(),
          ),
        ),
        title: const Text('تفاصيل المستأجر', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D47C9).withValues(alpha: 0.08),
                border: Border.all(color: const Color(0xFF0D47C9).withValues(alpha: 0.2), width: 3),
              ),
              child: Center(
                child: Text(t.name[0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D47C9))),
              ),
            ),
            const SizedBox(height: 16),
            Text(t.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.contractStatus == 'نشط' ? Icons.check_circle : t.contractStatus == 'منتهي' ? Icons.cancel : Icons.access_time, size: 16, color: statusColor),
                  const SizedBox(width: 6),
                  Text(t.contractStatus, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: statusColor)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    _DetailRow(icon: Icons.phone, label: 'رقم الهاتف', value: t.phone),
                    const Divider(height: 20, color: Color(0xFFF2F4F7)),
                    _DetailRow(icon: Icons.email_outlined, label: 'البريد الإلكتروني', value: t.email),
                    const Divider(height: 20, color: Color(0xFFF2F4F7)),
                    _DetailRow(icon: Icons.business, label: 'العقار', value: t.property),
                    const Divider(height: 20, color: Color(0xFFF2F4F7)),
                    _DetailRow(icon: Icons.location_on, label: 'الموقع', value: t.propertyLocation),
                    const Divider(height: 20, color: Color(0xFFF2F4F7)),
                    _DetailRow(icon: Icons.date_range, label: 'مدة الإيجار', value: '${t.contractFrom} - ${t.contractTo}'),
                    const Divider(height: 20, color: Color(0xFFF2F4F7)),
                    _DetailRow(icon: Icons.payments_outlined, label: 'إجمالي المدفوعات', value: '${t.totalPayments.toStringAsFixed(0)} SAR', bold: true),
                    const Divider(height: 20, color: Color(0xFFF2F4F7)),
                    _DetailRow(icon: Icons.history, label: 'الحجوزات السابقة', value: '${t.previousBookings} حجوزات'),
                    const Divider(height: 20, color: Color(0xFFF2F4F7)),
                    _DetailRow(icon: Icons.star, label: 'التقييم', value: t.rating.toString(), valueColor: const Color(0xFFF57C00)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('اتصال', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47C9),
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('مراسلة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D47C9),
                          side: const BorderSide(color: Color(0xFF0D47C9)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool bold;
  final Color? valueColor;
  const _DetailRow({required this.icon, required this.label, required this.value, this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0D47C9)),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A24))),
        const Spacer(),
        Text(value, style: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: valueColor ?? const Color(0xFF1A1A24),
        )),
      ],
    );
  }
}
