import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_request.dart';
import 'booking_request_detail_sheet.dart';

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  final _searchController = TextEditingController();
  int _selectedFilter = 0;
  final _allRequests = BookingRequest.samples;

  List<BookingRequest> get _filtered {
    final q = _searchController.text;
    var items = _allRequests;
    if (_selectedFilter > 0) {
      const statuses = ['', 'قيد المراجعة', 'تم القبول', 'تم الرفض'];
      items = items.where((r) => r.status == statuses[_selectedFilter]).toList();
    }
    if (q.isNotEmpty) {
      items = items.where((r) => r.tenantName.contains(q) || r.propertyName.contains(q)).toList();
    }
    return items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1A24)),
            onPressed: () {},
          ),
        ),
        title: const Text('طلبات الحجز', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5)),
              child: const Icon(Icons.person, size: 22, color: Color(0xFF9E9E9E)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ابحث عن مستأجر أو عقار...',
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFF0D47C9))),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                prefixIcon: const Icon(Icons.search, color: AppColors.grey, size: 22),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: ['الكل', 'قيد المراجعة', 'تم القبول', 'تم الرفض'].asMap().entries.map((e) {
                final i = e.key;
                final label = e.value;
                final selected = _selectedFilter == i;
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF16305C) : AppColors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: selected ? const Color(0xFF16305C) : const Color(0xFFE2E8F0)),
                      ),
                      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? AppColors.white : const Color(0xFF9E9E9E))),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text('لا توجد طلبات', style: TextStyle(fontSize: 14, color: AppColors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _BookingCard(request: items[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingRequest request;
  const _BookingCard({required this.request});

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
      margin: const EdgeInsets.only(bottom: 14),
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
