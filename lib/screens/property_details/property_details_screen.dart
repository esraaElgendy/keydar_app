import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/app_controller.dart';
import '../../models/property.dart';
import '../../models/sample_data.dart';
import '../../widgets/cards/property_card.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property? property;
  const PropertyDetailsScreen({super.key, this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ctrl = Get.find<AppController>();
  late Property property;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    property = widget.property ?? Get.arguments as Property;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prop = property;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _ImageGallery(prop: prop),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _PropertyInfo(prop: prop),
                        const SizedBox(height: 20),
                        _DetailsTabs(tabController: _tabController),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _DescriptionTab(prop: prop),
                              _AmenitiesTab(),
                              SingleChildScrollView(child: _ReviewsTab()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _LocationSection(prop: prop),
                        const SizedBox(height: 20),
                        _SimilarProperties(prop: prop),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BottomBookingButton(prop: prop),
        ],
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final Property prop;
  const _ImageGallery({required this.prop});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    return Stack(
      children: [
        Image.asset(
          AppAssets.building,
          height: 280,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            height: 280, color: AppColors.darkBlue,
            child: const Icon(Icons.image, color: AppColors.white, size: 60),
          ),
        ),
        Positioned(top: 50, right: 16, child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
            child: const Icon(Icons.arrow_forward, color: AppColors.black, size: 20),
          ),
        )),
        Positioned(top: 50, left: 16, child: Row(
          children: [
            GestureDetector(
              onTap: () => ctrl.toggleFavorite(prop),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
                child: Obx(() => Icon(
                  ctrl.isFavorite(prop) ? Icons.favorite : Icons.favorite_border,
                  color: ctrl.isFavorite(prop) ? Colors.red : AppColors.black,
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
        Positioned(bottom: 16, left: 0, right: 0, child: Center(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) => Container(
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
                  ),
                  child: i == 5 ? Center(
                    child: Text('+10', style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ) : null,
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }
}

class _PropertyInfo extends StatelessWidget {
  final Property prop;
  const _PropertyInfo({required this.prop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(prop.type, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            const Spacer(),
            Row(
              children: [
                Text(prop.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.black)),
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                const Text('(50 تقييم)', style: TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(prop.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.black)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(prop.location, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            const SizedBox(width: 4),
            const Icon(Icons.location_on, color: AppColors.primary, size: 16),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(prop.price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(width: 4),
            Text('/ شهرياً', style: const TextStyle(fontSize: 13, color: AppColors.grey)),
          ],
        ),
      ],
    );
  }
}

class _DetailsTabs extends StatelessWidget {
  final TabController tabController;
  const _DetailsTabs({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.fieldBorder)),
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'الوصف'),
          Tab(text: 'المرافق'),
          Tab(text: 'التقييمات'),
        ],
      ),
    );
  }
}

class _DescriptionTab extends StatelessWidget {
  final Property prop;
  const _DescriptionTab({required this.prop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('وصف العقار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        Text(
          prop.description,
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 13, color: AppColors.grey, height: 1.6),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('اقرأ المزيد', style: TextStyle(fontSize: 12, color: AppColors.primary)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _SpecBox(icon: Icons.bathtub_outlined, label: '${prop.bathrooms} حمام')),
            const SizedBox(width: 8),
            Expanded(child: _SpecBox(icon: Icons.bed_outlined, label: '${prop.bedrooms} غرف النوم')),
            const SizedBox(width: 8),
            Expanded(child: _SpecBox(icon: Icons.layers_outlined, label: 'الخامس الدور')),
            const SizedBox(width: 8),
            Expanded(child: _SpecBox(icon: Icons.straighten, label: '${prop.area} المساحة')),
          ],
        ),
      ],
    );
  }
}

class _SpecBox extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecBox({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.black)),
        ],
      ),
    );
  }
}

class _AmenitiesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final kitchenItems = [
      ('مطبخ كامل', Icons.kitchen),
      ('ثلاجة', Icons.ac_unit),
      ('فريزر', Icons.snowing),
      ('بوتجاز', Icons.local_fire_department),
      ('ميكروويف', Icons.wifi),
      ('غلاية', Icons.coffee_maker),
    ];
    final bathItems = [
      ('دش حديث', Icons.shower),
      ('سخان مياه', Icons.water_drop),
      ('مناشف', Icons.dry_cleaning),
      ('مرآة كبيرة', Icons.bathroom),
      ('غسالة', Icons.local_laundry_service),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('مرافق المطبخ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.black)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: kitchenItems.map((item) => _AmenityChip(label: item.$1, icon: item.$2)).toList(),
        ),
        const SizedBox(height: 20),
        const Text('مرافق الحمام', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.black)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: bathItems.map((item) => _AmenityChip(label: item.$1, icon: item.$2)).toList(),
        ),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _AmenityChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 68) / 4,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey)),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        ...SampleData.reviews.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withValues(alpha: 0.2), child: Text(r.name[0], style: const TextStyle(fontSize: 12, color: AppColors.primary))),
                  const SizedBox(width: 8),
                  Text(r.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                  const Spacer(),
                  Text(r.date, style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.6))),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(r.rating.toString(), style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                  const SizedBox(width: 4),
                  ...List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < r.rating.round() ? Colors.amber : AppColors.fieldBorder)),
                ],
              ),
              const SizedBox(height: 6),
              Text(r.comment, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: AppColors.grey, height: 1.5)),
              const Divider(height: 24),
            ],
          ),
        )),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
  final Property prop;
  const _LocationSection({required this.prop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الموقع و الخريطة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.map, color: AppColors.primary, size: 40),
                const SizedBox(height: 8),
                Text(prop.location, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SimilarProperties extends StatelessWidget {
  final Property prop;
  const _SimilarProperties({required this.prop});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    final similar = ctrl.filteredProperties.where((p) => p != prop).take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('عقارات مشابهة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
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
                final p = similar[i];
                return SizedBox(
                  width: 220,
                    child: PropertyCard(
                      property: p,
                      isFavorite: ctrl.isFavorite(p),
                      onFavoriteTap: () => ctrl.toggleFavorite(p),
                      onTap: () => Get.to(() => PropertyDetailsScreen(property: p)),
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

class _BottomBookingButton extends StatelessWidget {
  final Property prop;
  const _BottomBookingButton({required this.prop});

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
