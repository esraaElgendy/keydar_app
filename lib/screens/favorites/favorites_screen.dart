import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/app_controller.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/cards/car_card.dart';
import '../../widgets/cards/property_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // مزامنة المفضلة من السيرفر عند فتح الشاشة.
    Get.find<AppController>().syncFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();

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
                  const Text('المفضلة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_forward, color: AppColors.black, size: 22),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'العقارات'),
                Tab(text: 'السيارات'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _propertyFavorites(ctrl),
                    _carFavorites(ctrl),
                  ],
                ),
              ),
            ),
            AppBottomNav(currentIndex: 2, onTap: (i) {
              switch (i) {
                case 0: Get.offNamed(AppRoutes.home);
                case 1: Get.offNamed(AppRoutes.explore);
                case 2: break;
                case 3: Get.offNamed(AppRoutes.myBookings);
                case 4: Get.offNamed(AppRoutes.profile);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _propertyFavorites(AppController ctrl) {
    return Obx(() {
      if (ctrl.favorites.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 60, color: AppColors.grey.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              const Text('لا توجد عقارات في المفضلة', style: TextStyle(color: AppColors.grey)),
              const SizedBox(height: 4),
              Text('اضغط على القلب لإضافة عقار', style: TextStyle(fontSize: 12, color: AppColors.grey.withValues(alpha: 0.6))),
            ],
          ),
        );
      }
      return ListView.builder(
        itemCount: ctrl.favorites.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PropertyCard(
            property: ctrl.favorites[i],
            isFavorite: true,
            onFavoriteTap: () => ctrl.toggleFavorite(ctrl.favorites[i]),
            onTap: () => Get.toNamed(AppRoutes.propertyDetails, arguments: ctrl.favorites[i]),
          ),
        ),
      );
    });
  }

  Widget _carFavorites(AppController ctrl) {
    return Obx(() {
      if (ctrl.carFavorites.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 60, color: AppColors.grey.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              const Text('لا توجد سيارات في المفضلة', style: TextStyle(color: AppColors.grey)),
              const SizedBox(height: 4),
              Text('اضغط على القلب لإضافة سيارة', style: TextStyle(fontSize: 12, color: AppColors.grey.withValues(alpha: 0.6))),
            ],
          ),
        );
      }
      return ListView.builder(
        itemCount: ctrl.carFavorites.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CarCard(
            car: ctrl.carFavorites[i],
            isFavorite: true,
            onFavoriteTap: () => ctrl.toggleCarFavorite(ctrl.carFavorites[i]),
            onTap: () => Get.toNamed(AppRoutes.carDetails, arguments: ctrl.carFavorites[i]),
          ),
        ),
      );
    });
  }
}
