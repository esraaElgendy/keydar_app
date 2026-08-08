import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/booking_request.dart';
import '../booking_requests/booking_request_detail_sheet.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fieldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.menu, color: AppColors.black),
            onPressed: () {},
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.grey),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: const Color(0xFF0D47C9).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.bar_chart_rounded, size: 16, color: Color(0xFF0D47C9)),
                ),
                const SizedBox(width: 8),
                const Text('إحصائياتي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'الوحدات المتاحة',
                    value: '12',
                    icon: Icons.home_work,
                    color: const Color(0xFFF57C00),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'إجمالي العقارات',
                    value: '18',
                    icon: Icons.business,
                    color: const Color(0xFF0D47C9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'طلبات جديدة',
                    value: '5',
                    icon: Icons.fiber_new,
                    color: const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'المؤجرة',
                    value: '6',
                    icon: Icons.check_circle,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
                    child: const Icon(Icons.credit_card, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(height: 14),
                  const Text('إجمالي الدخل', style: TextStyle(fontSize: 12, color: Color(0xFFB0D4FF))),
                  const SizedBox(height: 6),
                  const Text(
                    '125,500 ر.س',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'طلبات الحجز',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.bookingRequests),
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...BookingRequest.samples.take(2).map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _BookingRequestPreview(request: r),
            )),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Get.toNamed(AppRoutes.myProperties);
          } else if (index == 2) {
            Get.toNamed(AppRoutes.myBookings);
          } else if (index == 3) {
            Get.toNamed(AppRoutes.profile);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'عقاراتي'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'حجوزاتي'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
              Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7))),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _BookingRequestPreview extends StatelessWidget {
  final BookingRequest request;
  const _BookingRequestPreview({required this.request});

  Color _statusColor() {
    switch (request.status) {
      case 'قيد المراجعة': return const Color(0xFF0D47C9);
      case 'تم القبول': return const Color(0xFF2E7D32);
      case 'تم الرفض': return const Color(0xFFD32F2F);
      default: return const Color(0xFF9E9E9E);
    }
  }

  Color _statusBg() {
    switch (request.status) {
      case 'قيد المراجعة': return const Color(0xFFE3EDF7);
      case 'تم القبول': return const Color(0xFFE8F5E9);
      case 'تم الرفض': return const Color(0xFFFFEBEE);
      default: return const Color(0xFFF5F5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100, height: 90,
                  color: const Color(0xFF0D47C9).withValues(alpha: 0.08),
                  child: const Icon(Icons.person, size: 36, color: Color(0xFF0D47C9)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: _statusBg(), borderRadius: BorderRadius.circular(8)),
                      child: Text(request.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor())),
                    ),
                    const SizedBox(height: 8),
                    Text(request.tenantName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                    const SizedBox(height: 4),
                    Text('${request.propertyName} - ${request.location}', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                    const SizedBox(height: 10),
                    Text(request.price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47C9))),
                    const SizedBox(height: 2),
                    Text('${request.dateFrom} - ${request.dateTo} (${request.nights} ليالي)', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD32F2F),
                    side: const BorderSide(color: Color(0xFFD32F2F)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('رفض', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47C9),
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text('قبول', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10)),
                child: IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 20, color: Color(0xFF1A1A24)),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BookingRequestDetailSheet(request: request),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
