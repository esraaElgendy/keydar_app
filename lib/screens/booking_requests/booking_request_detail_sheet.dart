import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_request.dart';

class BookingRequestDetailSheet extends StatelessWidget {
  final BookingRequest request;
  const BookingRequestDetailSheet({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    _SheetHeader(),
                    _ProfileSection(request: request),
                    const SizedBox(height: 20),
                    _ContactRow(),
                    const SizedBox(height: 24),
                    _PropertyCard(request: request),
                    const SizedBox(height: 24),
                    _FinancialGrid(request: request),
                    const SizedBox(height: 24),
                    _TimelineSection(request: request),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              _StickyFooter(request: request),
            ],
          ),
        );
      },
    );
  }
}

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, size: 22, color: Color(0xFF1A1A24)),
          ),
          const Spacer(),
          const Text('تفاصيل الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final BookingRequest request;
  const _ProfileSection({required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0D47C9).withValues(alpha: 0.08), border: Border.all(color: const Color(0xFF0D47C9).withValues(alpha: 0.2), width: 2)),
          child: Center(child: Text(request.tenantName[0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D47C9)))),
        ),
        const SizedBox(height: 14),
        Text(request.tenantName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
        const SizedBox(height: 4),
        Text('رقم الطلب: ${request.id}', style: const TextStyle(fontSize: 13, color: AppColors.grey)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFE3EDF7), borderRadius: BorderRadius.circular(20)),
          child: Text(request.status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0D47C9))),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2E7D32), width: 1.5)),
          child: const Icon(Icons.chat_bubble_outline, size: 24, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(width: 20),
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0D47C9), width: 1.5)),
          child: const Icon(Icons.phone_outlined, size: 24, color: Color(0xFF0D47C9)),
        ),
      ],
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final BookingRequest request;
  const _PropertyCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 72, height: 72,
                    color: const Color(0xFFE2E8F0),
                    child: const Icon(Icons.king_bed, size: 32, color: Color(0xFFB0BEC5)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${request.propertyName} - ${request.location.split('، ').last}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                      const SizedBox(height: 4),
                      Text(request.propertyType, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFF0D47C9)),
              const SizedBox(width: 6),
              Text(request.address, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinancialGrid extends StatelessWidget {
  final BookingRequest request;
  const _FinancialGrid({required this.request});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FC), borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _FinanceCell(label: 'التاريخ', value: '${request.dateFrom} - ${request.dateTo}')),
                const SizedBox(width: 12),
                Expanded(child: _FinanceCell(label: 'المبلغ الإجمالي', value: request.price, bold: true, valueColor: const Color(0xFF0D47C9))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _FinanceCell(label: 'حالة الدفع', value: request.paymentStatus, valueColor: const Color(0xFF2E7D32))),
                const SizedBox(width: 12),
                Expanded(child: _FinanceCell(label: 'وسيلة الدفع', value: request.paymentMethod)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceCell extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? valueColor;
  const _FinanceCell({required this.label, required this.value, this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: bold ? 16 : 13, fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: valueColor ?? const Color(0xFF1A1A24))),
      ],
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final BookingRequest request;
  const _TimelineSection({required this.request});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الجدول الزمني', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Color(0xFF0D47C9)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تم إنشاء الطلب', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A24))),
                  const SizedBox(height: 2),
                  Text(request.orderDate, style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StickyFooter extends StatelessWidget {
  final BookingRequest request;
  const _StickyFooter({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                side: const BorderSide(color: Color(0xFFD32F2F)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('رفض الطلب', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16305C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: const Text('قبول الطلب', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
