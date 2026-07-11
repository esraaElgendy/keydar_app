import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/app_controller.dart';
import '../../models/property.dart';
import '../../widgets/cards/car_card.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car? car;
  const CarDetailsScreen({super.key, this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> with SingleTickerProviderStateMixin {
  late Car car;
  late TabController _tabController;
  final ctrl = Get.find<AppController>();

  @override
  void initState() {
    super.initState();
    car = widget.car ?? Get.arguments as Car;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _CarImage(car: car),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _CarInfo(car: car),
                          const SizedBox(height: 20),
                          TabBar(
                            controller: _tabController,
                            indicatorColor: AppColors.primary,
                            indicatorWeight: 3,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: AppColors.grey,
                            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            tabs: const [
                              Tab(text: 'الوصف'),
                              Tab(text: 'المواصفات'),
                              Tab(text: 'التقييمات'),
                            ],
                          ),
                          SizedBox(
                            height: 400,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _CarDescriptionTab(car: car),
                                _CarSpecsTab(car: car),
                                _CarReviewsTab(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _CarLocationSection(),
                          const SizedBox(height: 20),
                          _SimilarCars(car: car),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomRentButton(car: car),
          ],
        ),
      ),
    );
  }
}

class _CarImage extends StatelessWidget {
  final Car car;
  const _CarImage({required this.car});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    return Stack(
      children: [
        Image.asset(
          AppAssets.car,
          height: 280,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            height: 280, color: AppColors.darkBlue,
            child: const Icon(Icons.directions_car, color: AppColors.white, size: 60),
          ),
        ),
        Positioned(top: 50, right: 16, child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
                child: const Icon(Icons.arrow_forward, color: AppColors.black, size: 20),
              ),
            ),
            if (car.isAvailable) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                child: const Text('متاحة الآن', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        )),
        Positioned(top: 50, left: 16, child: Row(
          children: [
            GestureDetector(
              onTap: () => ctrl.toggleCarFavorite(car),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
                child: Obx(() => Icon(
                  ctrl.isCarFavorite(car) ? Icons.favorite : Icons.favorite_border,
                  color: ctrl.isCarFavorite(car) ? Colors.red : AppColors.black,
                  size: 20,
                )),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
              child: const Icon(Icons.share_outlined, color: AppColors.black, size: 20),
            ),
          ],
        )),
      ],
    );
  }
}

class _CarInfo extends StatelessWidget {
  final Car car;
  const _CarInfo({required this.car});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(car.category, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            const Spacer(),
            Row(
              children: [
                Text(car.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.black)),
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                const Text('(25 تقييم)', style: TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('${car.name} ${car.model}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.black)),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(car.price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(width: 4),
            Text('/ شهرياً', style: const TextStyle(fontSize: 13, color: AppColors.grey)),
          ],
        ),
      ],
    );
  }
}

class _CarDescriptionTab extends StatelessWidget {
  final Car car;
  const _CarDescriptionTab({required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('وصف السيارة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
          const SizedBox(height: 8),
          Text(
            car.description,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13, color: AppColors.grey, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _CarSpecsTab extends StatelessWidget {
  final Car car;
  const _CarSpecsTab({required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('المواصفات الفنية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
          const SizedBox(height: 16),
          _CarSpecRow(icon: Icons.settings, label: 'ناقل الحركة', value: car.transmission),
          const Divider(height: 24),
          _CarSpecRow(icon: Icons.local_gas_station, label: 'الوقود', value: car.fuel),
          const Divider(height: 24),
          _CarSpecRow(icon: Icons.people_outline, label: 'المقاعد', value: '${car.seats} ركاب'),
          const Divider(height: 24),
          _CarSpecRow(icon: Icons.calendar_today, label: 'الموديل', value: car.model),
        ],
      ),
    );
  }
}

class _CarSpecRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _CarSpecRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black)),
      ],
    );
  }
}

class _CarReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('التقييمات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
          const SizedBox(height: 16),
          Center(child: Text('لا توجد تقييمات بعد', style: TextStyle(fontSize: 13, color: AppColors.grey))),
        ],
      ),
    );
  }
}

class _CarLocationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('موقع الاستلام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map, color: AppColors.primary, size: 40),
                SizedBox(height: 8),
                Text('خريطة موقع التسليم', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SimilarCars extends StatelessWidget {
  final Car car;
  const _SimilarCars({required this.car});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    final similar = ctrl.filteredCars.where((c) => c != car).take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('سيارات مشابهة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
        const SizedBox(height: 12),
        Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: similar.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final c = similar[i];
                return SizedBox(
                  width: 220,
                  child: CarCard(
                    car: c,
                    isFavorite: ctrl.isCarFavorite(c),
                    onFavoriteTap: () => ctrl.toggleCarFavorite(c),
                    onTap: () => Get.to(() => CarDetailsScreen(car: c)),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomRentButton extends StatelessWidget {
  final Car car;
  const _BottomRentButton({required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.bookingConfirmation),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 6,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
            ),
            child: const Text('احجز الآن', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
