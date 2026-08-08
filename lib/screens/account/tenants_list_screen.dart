import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/tenant.dart';

class TenantsListScreen extends StatefulWidget {
  const TenantsListScreen({super.key});

  @override
  State<TenantsListScreen> createState() => _TenantsListScreenState();
}

class _TenantsListScreenState extends State<TenantsListScreen> {
  final _searchController = TextEditingController();
  final _allTenants = tenants;
  List<Tenant> get _filtered {
    final q = _searchController.text;
    if (q.isEmpty) return _allTenants;
    return _allTenants.where((t) => t.name.contains(q) || t.property.contains(q)).toList();
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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A24)),
            onPressed: () => Get.back(),
          ),
        ),
        title: const Text('المستأجرون', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'ابحث عن مستأجر',
                  hintStyle: TextStyle(fontSize: 14, color: AppColors.grey),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: Icon(Icons.search, color: AppColors.grey, size: 22),
                ),
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text('لا يوجد مستأجرون', style: TextStyle(fontSize: 14, color: AppColors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final t = items[i];
                      final statusColor = t.contractStatus == 'نشط'
                          ? const Color(0xFF2E7D32)
                          : t.contractStatus == 'منتهي'
                              ? AppColors.grey
                              : const Color(0xFFE65100);
                      final statusIcon = t.contractStatus == 'نشط'
                          ? Icons.check_circle
                          : t.contractStatus == 'منتهي'
                              ? Icons.cancel
                              : Icons.access_time;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                          child: GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.tenantDetail, arguments: t),
                            child: Row(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D47C9).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(t.name[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47C9))),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(t.rating.toString(), style: const TextStyle(fontSize: 13, color: Color(0xFFF57C00))),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.star, size: 14, color: Color(0xFFF57C00)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(t.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(statusIcon, size: 14, color: statusColor),
                                          const SizedBox(width: 6),
                                          Text(t.contractStatus, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey),
                                      onPressed: () => Get.toNamed(AppRoutes.tenantDetail, arguments: t),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
