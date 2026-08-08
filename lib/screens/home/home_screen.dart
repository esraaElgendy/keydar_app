import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/cards/property_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AppController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => Future.wait([
                  ctrl.fetchLatestProperties(silent: true),
                  ctrl.fetchAllProperties(silent: true),
                ]),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 16),
                      const _Header(),
                      const SizedBox(height: 16),
                      _SearchBar(ctrl: ctrl),
                      const SizedBox(height: 16),
                      const _BannerCarousel(),
                      const SizedBox(height: 20),
                      const _SectionHeader(title: 'أحدث الإيجارات', onViewAll: _goExplore),
                      const SizedBox(height: 12),
                      _HorizontalPropertyList(ctrl: ctrl),
                      const SizedBox(height: 20),
                      _CategoryTabs(ctrl: ctrl),
                      const SizedBox(height: 12),
                      _VerticalPropertyList(ctrl: ctrl),
                      const SizedBox(height: 20),
                      const _CarRentalBanner(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            AppBottomNav(currentIndex: 0, onTap: (i) {
              switch (i) {
                case 0: break;
                case 1: Get.toNamed(AppRoutes.explore);
                case 2: Get.toNamed(AppRoutes.favorites);
                case 3: Get.toNamed(AppRoutes.myBookings);
                case 4: Get.toNamed(AppRoutes.profile);
              }
            }),
          ],
        ),
      ),
    );
  }
}

void _goExplore() => Get.toNamed(AppRoutes.explore);

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(() {
          final firstName = AuthController.instance.customer.value?.firstName?.trim();
          final greeting = (firstName != null && firstName.isNotEmpty) ? firstName : 'محمد';
          return Text('مرحباً، $greeting 👋', style: const TextStyle(fontSize: 14, color: AppColors.grey));
        }),
        const Spacer(),
        Stack(
          children: [
            Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
              child: const Icon(Icons.notifications_outlined, color: AppColors.black, size: 24),
            ),
            Positioned(top: 10, right: 10, child: Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
            )),
          ],
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final AppController ctrl;
  const _SearchBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              textDirection: TextDirection.rtl,
              onChanged: (v) => ctrl.setSearch(v),
              decoration: InputDecoration(
                hintText: 'ابحث عن حي، مدينة...',
                hintTextDirection: TextDirection.rtl,
                hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search, color: AppColors.grey.withValues(alpha: 0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
          child: IconButton(
            onPressed: () => Get.toNamed(AppRoutes.filter),
            icon: const Icon(Icons.tune, color: AppColors.white, size: 22),
          ),
        ),
      ],
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  const _BannerCarousel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Image.asset(AppAssets.building, height: 160, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(height: 160, color: AppColors.darkBlue),
          ),
          Container(height: 160, decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54],
            ),
          )),
          Positioned(
            left: 0, right: 0, bottom: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('استأجر راحتك وين ما تكون', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
                const SizedBox(height: 6),
                Text('شقق وفنادق للإيجار اليومي، الشهري، أو السنوي — بكل سهولة وثقة.', style: TextStyle(fontSize: 12, color: AppColors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
          Positioned(
            bottom: 12, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == 0 ? 20 : 8, height: 8,
                decoration: BoxDecoration(
                  color: i == 0 ? AppColors.primary : AppColors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
        const Spacer(),
        TextButton(onPressed: onViewAll, child: const Text('عرض الكل', style: TextStyle(fontSize: 13, color: AppColors.primary))),
      ],
    );
  }
}

class _HorizontalPropertyList extends StatelessWidget {
  final AppController ctrl;
  const _HorizontalPropertyList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.latestLoading.value && ctrl.latestProperties.isEmpty) {
        return const SizedBox(
          height: 270,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
          ),
        );
      }
      if (ctrl.latestError.value != null && ctrl.latestProperties.isEmpty) {
        return SizedBox(
          height: 180,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, color: AppColors.grey, size: 34),
                const SizedBox(height: 8),
                Text(
                  ctrl.latestError.value!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.grey),
                ),
                TextButton(
                  onPressed: ctrl.retryLatest,
                  child: const Text('إعادة المحاولة', style: TextStyle(fontSize: 13, color: AppColors.primary)),
                ),
              ],
            ),
          ),
        );
      }
      final properties = ctrl.latestFilteredProperties;
      if (properties.isEmpty) {
        return const SizedBox(
          height: 150,
          child: Center(child: Text('لا توجد نتائج', style: TextStyle(color: AppColors.grey))),
        );
      }
      return SizedBox(
        height: 270,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: properties.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 200,
              child: PropertyCard(
                property: properties[i],
                isFavorite: ctrl.isFavorite(properties[i]),
                onFavoriteTap: () => ctrl.toggleFavorite(properties[i]),
                onTap: () => Get.toNamed(AppRoutes.propertyDetails, arguments: properties[i]),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _CategoryTabs extends StatelessWidget {
  final AppController ctrl;
  const _CategoryTabs({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final categories = ['الجميع', 'فلل', 'شقق', 'مكاتب'];
    return Obx(() {
      final selected = ctrl.selectedCategoryIndex.value;
      return SizedBox(
        height: 38,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => ctrl.selectedCategoryIndex.value = i,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: i == selected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(19),
                  border: i == selected ? null : Border.all(color: AppColors.fieldBorder),
                ),
                child: Center(
                  child: Text(categories[i], style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: i == selected ? AppColors.white : AppColors.black,
                  )),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _VerticalPropertyList extends StatelessWidget {
  final AppController ctrl;
  const _VerticalPropertyList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.allLoading.value && ctrl.allProperties.isEmpty) {
        return const SizedBox(
          height: 160,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
          ),
        );
      }
      if (ctrl.allError.value != null && ctrl.allProperties.isEmpty) {
        return SizedBox(
          height: 180,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, color: AppColors.grey, size: 34),
                const SizedBox(height: 8),
                Text(
                  ctrl.allError.value!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.grey),
                ),
                TextButton(
                  onPressed: ctrl.retryAll,
                  child: const Text('إعادة المحاولة', style: TextStyle(fontSize: 13, color: AppColors.primary)),
                ),
              ],
            ),
          ),
        );
      }
      final properties = ctrl.categoryFilteredProperties;
      if (properties.isEmpty) {
        return const SizedBox(
          height: 150,
          child: Center(child: Text('لا توجد عقارات', style: TextStyle(color: AppColors.grey))),
        );
      }
      return Column(
        children: List.generate(properties.length, (i) {
          final p = properties[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 270,
              child: PropertyCard(
                property: p,
                isFavorite: ctrl.isFavorite(p),
                onFavoriteTap: () => ctrl.toggleFavorite(p),
                onTap: () => Get.toNamed(AppRoutes.propertyDetails, arguments: p),
              ),
            ),
          );
        }),
      );
    });
  }
}

class _CarRentalBanner extends StatelessWidget {
  const _CarRentalBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFFF9800).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                  child: const Text('خدمة إضافية', style: TextStyle(fontSize: 10, color: Color(0xFFE65100), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                const Text('تحتاج سيارة لنقلك؟', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.explore, arguments: {'carsTab': true}),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('تصفح السيارات', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: Color(0xFFE65100), size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(AppAssets.car, width: 100, height: 80, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: AppColors.white, child: const Icon(Icons.directions_car, size: 40, color: AppColors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}
