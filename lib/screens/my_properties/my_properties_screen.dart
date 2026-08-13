import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/property.dart';
import '../owner_property_detail/owner_property_detail_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = Get.find<AppController>();
      if (ctrl.ownerProperties.isEmpty) {
        ctrl.fetchOwnerMyProperties();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Property> _filtered(List<Property> all) {
    final ctrl = Get.find<AppController>();
    final q = _searchController.text;
    final catIndex = ctrl.selectedCategoryIndex.value;
    var list = all;
    if (q.isNotEmpty) {
      list = list.where((p) =>
        p.title.contains(q) || p.location.contains(q)
      ).toList();
    }
    if (catIndex == 1) {
      list = list.where((p) => p.badge1 == 'مؤجرة').toList();
    } else if (catIndex == 2) {
      list = list.where((p) => p.badge1 == 'متاحة').toList();
    } else if (catIndex == 3) {
      list = list.where((p) => p.badge1 == 'قيد المراجعة').toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    return Scaffold(
      backgroundColor: AppColors.fieldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'عقاراتي',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
        ),
      ),
      body: Obx(() {
        final all = ctrl.ownerProperties;
        final properties = _filtered(all.toList());
        final isLoading = ctrl.ownerPropertiesLoading.value;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن عقار...',
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                height: 28,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _CategoryChip(label: 'الكل', isActive: ctrl.selectedCategoryIndex.value == 0, onTap: () => ctrl.selectedCategoryIndex.value = 0),
                    const SizedBox(width: 6),
                    _CategoryChip(label: 'مؤجرة', isActive: ctrl.selectedCategoryIndex.value == 1, onTap: () => ctrl.selectedCategoryIndex.value = 1),
                    const SizedBox(width: 6),
                    _CategoryChip(label: 'متاحة', isActive: ctrl.selectedCategoryIndex.value == 2, onTap: () => ctrl.selectedCategoryIndex.value = 2),
                    const SizedBox(width: 6),
                    _CategoryChip(label: 'قيد المراجعة', isActive: ctrl.selectedCategoryIndex.value == 3, onTap: () => ctrl.selectedCategoryIndex.value = 3),
                  ],
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : properties.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.business_outlined, size: 64, color: AppColors.grey.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          const Text('لا توجد عقارات', style: TextStyle(fontSize: 16, color: AppColors.grey)),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Get.toNamed(AppRoutes.addProperty),
                            child: const Text('أضف عقارك الأول', style: TextStyle(fontSize: 14, color: AppColors.primary)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: properties.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _AddPropertyCard(
                              onTap: () => Get.toNamed(AppRoutes.addProperty),
                            ),
                          );
                        }
                        final p = properties[i - 1];
                        final statusColor = p.badge1 == 'متاحة' ? const Color(0xFF4CAF50)
                            : p.badge1 == 'مؤجرة' ? const Color(0xFFFF9800)
                            : p.badge1 == 'قيد المراجعة' ? const Color(0xFF9E9E9E)
                            : const Color(0xFF4CAF50);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _PropertyCard(
                            title: p.title,
                            location: p.location,
                            price: p.price,
                            period: p.period,
                            status: p.badge1,
                            statusColor: statusColor,
                            imageUrl: p.imageUrl,
                            rooms: p.bedrooms.toString(),
                            baths: p.bathrooms.toString(),
                            area: p.area.toStringAsFixed(0),
                            onTap: () => Get.to(() => OwnerPropertyDetailScreen(property: p)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Get.toNamed(AppRoutes.ownerDashboard);
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.white : AppColors.grey,
          ),
        ),
      ),
    );
  }
}

class _AddPropertyCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPropertyCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary, size: 32),
            SizedBox(width: 12),
            Text(
              'إضافة عقار جديد',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final String title, location, price, period, status, rooms, baths, area;
  final String? imageUrl;
  final Color statusColor;
  final VoidCallback onTap;
  const _PropertyCard({
    required this.title, required this.location, required this.price,
    required this.period, required this.status, required this.statusColor,
    required this.imageUrl,
    required this.rooms, required this.baths, required this.area,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.6), width: 0.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                          const SizedBox(height: 4),
                          Text(location, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor)),
                              const SizedBox(width: 4),
                              Text(status, style: TextStyle(fontSize: 12, color: statusColor)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText), overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 4),
                              Text('/ ${_periodLabel(period)}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(child: _SpecItem(icon: Icons.bed, text: '$rooms غرف')),
                              const SizedBox(width: 12),
                              Expanded(child: _SpecItem(icon: Icons.bathroom, text: '$baths حمام')),
                              const SizedBox(width: 12),
                              Expanded(child: _SpecItem(icon: Icons.square_foot, text: '$area م²')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        width: 100, height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _periodLabel(String period) {
    switch (period) {
      case 'يومياً':
      case 'daily':
        return 'يومياً';
      case 'سنوياً':
      case 'yearly':
        return 'سنوياً';
      default:
        return 'شهرياً';
    }
  }

  Widget _imagePlaceholder() => Container(
        width: 100, height: 120,
        color: AppColors.darkBlue,
        child: const Icon(Icons.business, color: AppColors.white, size: 40),
      );
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SpecItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 3),
        Flexible(
          child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.grey), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
