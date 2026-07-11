import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/app_controller.dart';
import '../../models/sample_data.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/cards/car_card.dart';
import '../../widgets/cards/property_card.dart';

class ExploreScreen extends StatefulWidget {
  final bool initialCarsTab;
  const ExploreScreen({super.key, this.initialCarsTab = false});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late bool _isRealEstate;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final carsTab = args is Map ? args['carsTab'] == true : widget.initialCarsTab;
    _isRealEstate = !carsTab;
  }

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
                  const Text('أستكشف', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_forward, color: AppColors.black, size: 22),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isRealEstate = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isRealEstate ? AppColors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _isRealEstate ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))] : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(child: Text('عقارات للإيجار', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _isRealEstate ? AppColors.primary : AppColors.grey))),
                              const SizedBox(width: 6),
                              Icon(Icons.business, size: 18, color: _isRealEstate ? AppColors.primary : AppColors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isRealEstate = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_isRealEstate ? AppColors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: !_isRealEstate ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))] : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(child: Text('تأجير سيارات', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _isRealEstate ? AppColors.grey : AppColors.primary))),
                              const SizedBox(width: 6),
                              Icon(Icons.directions_car, size: 18, color: _isRealEstate ? AppColors.grey : AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _isRealEstate ? _propertyGrid() : _carGrid(),
              ),
            ),
            AppBottomNav(currentIndex: 1, onTap: (i) {
              switch (i) {
                case 0: Get.offNamed(AppRoutes.home);
                case 1: break;
                case 2: Get.offNamed(AppRoutes.myBookings);
                case 3: Get.offNamed(AppRoutes.favorites);
                case 4: Get.offNamed(AppRoutes.profile);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _propertyGrid() {
    final ctrl = Get.find<AppController>();
    return ListView.builder(
      key: ValueKey('prop_${ctrl.favorites.length}'),
      itemCount: SampleData.properties.length * 2,
      itemBuilder: (_, i) {
        final p = SampleData.properties[i % SampleData.properties.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PropertyCard(
            property: p,
            isFavorite: ctrl.isFavorite(p),
            onFavoriteTap: () => ctrl.toggleFavorite(p),
            onTap: () => Get.toNamed(AppRoutes.propertyDetails, arguments: p),
          ),
        );
      },
    );
  }

  Widget _carGrid() {
    final ctrl = Get.find<AppController>();
    return ListView.builder(
      key: ValueKey('car_${ctrl.carFavorites.length}'),
      itemCount: SampleData.cars.length * 2,
      itemBuilder: (_, i) {
        final c = SampleData.cars[i % SampleData.cars.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CarCard(
            car: c,
            isFavorite: ctrl.isCarFavorite(c),
            onFavoriteTap: () => ctrl.toggleCarFavorite(c),
            onTap: () => Get.toNamed(AppRoutes.carDetails, arguments: c),
          ),
        );
      },
    );
  }
}
