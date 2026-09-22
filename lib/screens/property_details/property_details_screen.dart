import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../property_map/property_map_screen.dart';
import '../../core/utils/location_helper.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/property_detail_controller.dart';
import '../../core/constants/amenity_labels.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/review.dart';
import '../../models/property.dart';
import '../../models/sample_data.dart';
import '../../widgets/cards/property_card.dart';
import '../../widgets/video_player_widget.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property? property;
  const PropertyDetailsScreen({super.key, this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PropertyDetailController _ctrl = PropertyDetailController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _ctrl.load(fromList: widget.property ?? Get.arguments as Property);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Obx(() {
        final prop = _ctrl.property.value;
        final error = _ctrl.errorMessage.value;
        final loading = _ctrl.loading.value;
        if (prop == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return Column(
          children: [
            if (loading)
              const LinearProgressIndicator(color: AppColors.primary, minHeight: 2),
            if (error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                color: const Color(0xFFFFF3E0),
                child: Text(error, style: const TextStyle(fontSize: 12, color: Color(0xFFE65100))),
              ),
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
                          if (prop.videoUrl != null && prop.videoUrl!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.black,
                                      builder: (ctx) => SafeArea(
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: AspectRatio(
                                                aspectRatio: 16 / 9,
                                                child: VideoPlayerWidget(videoUrl: prop.videoUrl!),
                                              ),
                                            ),
                                            Positioned(
                                              top: 16,
                                              left: 16,
                                              child: IconButton(
                                                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                                onPressed: () => Navigator.pop(ctx),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.play_circle_fill, size: 20),
                                  label: const Text('مشاهدة فيديو العقار', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                            ),
                          _PropertyInfo(prop: prop, ctrl: _ctrl),
                          const SizedBox(height: 20),
                          _DetailsTabs(tabController: _tabController),
                          SizedBox(
                            height: 380,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                SingleChildScrollView(child: _DescriptionTab(prop: prop)),
                                SingleChildScrollView(child: _AmenitiesTab(prop: prop)),
                                SingleChildScrollView(child: _ReviewsTab(prop: prop, ctrl: _ctrl)),
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
        );
      }),
    );
  }
}

class _ImageGallery extends StatefulWidget {
  final Property prop;
  const _ImageGallery({required this.prop});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  late final PageController _pageCtrl;
  int _current = 0;

  List<String> get _images {
    final urls = <String>[];
    if (widget.prop.imageUrl != null && widget.prop.imageUrl!.isNotEmpty) {
      urls.add(widget.prop.imageUrl!);
    }
    for (final g in widget.prop.gallery) {
      if (!urls.contains(g)) urls.add(g);
    }
    return urls;
  }

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _openFullScreen(int initialIndex) {
    final imgs = _images;
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => _FullScreenGallery(images: imgs, initialIndex: initialIndex),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    final imgs = _images;
    return Stack(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: imgs.isEmpty
              ? Container(
                  color: AppColors.darkBlue,
                  child: const Icon(Icons.image, color: AppColors.white, size: 60),
                )
              : PageView.builder(
                  controller: _pageCtrl,
                  itemCount: imgs.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _openFullScreen(i),
                    child: Image.network(
                      imgs[i],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => Image.asset(
                        AppAssets.building,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.darkBlue,
                          child: const Icon(Icons.image, color: AppColors.white, size: 60),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 16,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
              child: const Icon(Icons.arrow_forward, color: AppColors.black, size: 20),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => ctrl.toggleFavorite(widget.prop),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
                  child: Obx(() => Icon(
                    ctrl.isFavorite(widget.prop) ? Icons.favorite : Icons.favorite_border,
                    color: ctrl.isFavorite(widget.prop) ? Colors.red : AppColors.black,
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
          ),
        ),
        if (imgs.length > 1)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_current + 1} / ${imgs.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        if (imgs.length > 1)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imgs.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: i == _current ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i == _current ? AppColors.white : AppColors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ),
        if (imgs.isNotEmpty)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SizedBox(
                  height: 46,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: imgs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () {
                        _pageCtrl.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                      child: Container(
                        width: 50,
                        height: 46,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: i == _current ? AppColors.white : AppColors.white.withValues(alpha: 0.4),
                            width: i == _current ? 2 : 1,
                          ),
                        ),
                        child: Image.network(imgs[i], fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.black.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _ctrl;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  widget.images[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image, color: Colors.white54, size: 60),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_current + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: i == _current ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == _current ? AppColors.white : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }
}

class _PropertyInfo extends StatelessWidget {
  final Property prop;
  final PropertyDetailController ctrl;
  const _PropertyInfo({required this.prop, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(prop.type, style: const TextStyle(fontSize: 12, color: AppColors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Spacer(),
            Row(
              children: [
                Text(prop.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.black)),
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Obx(() {
                  final count = ctrl.totalReviews.value > 0 ? ctrl.totalReviews.value : prop.reviewsCount;
                  return Text('($count تقييم)', style: const TextStyle(fontSize: 12, color: AppColors.grey));
                }),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(prop.title, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.black)),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Text(prop.location, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.location_on, color: AppColors.primary, size: 16),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: Text(prop.price, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
            const SizedBox(width: 4),
            Text(prop.period.isNotEmpty ? prop.period : '/ شهرياً', maxLines: 1,
                style: const TextStyle(fontSize: 13, color: AppColors.grey)),
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
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: AppColors.grey, height: 1.6),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: [
            _SpecBox(icon: Icons.bathtub_outlined, label: '${prop.bathrooms} حمام'),
            _SpecBox(icon: Icons.bed_outlined, label: '${prop.bedrooms} غرف'),
            _SpecBox(icon: Icons.people_outline, label: '${prop.guests} ضيوف'),
            _SpecBox(icon: Icons.straighten, label: '${prop.area.toStringAsFixed(0)} م²'),
          ],
        ),
        if (prop.furnishing != null && prop.furnishing!.isNotEmpty) ...[
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: [
              _SpecBox(icon: Icons.layers_outlined, label: prop.floor ?? '—'),
              _SpecBox(icon: Icons.chair_outlined, label: _furnishingLabel(prop.furnishing)),
              if (prop.city != null && prop.city!.isNotEmpty)
                _SpecBox(icon: Icons.location_city, label: prop.city!),
              if (prop.status != null && prop.status!.isNotEmpty)
                _SpecBox(icon: Icons.info_outline, label: _statusLabel(prop.status)),
            ],
          ),
        ] else
          const SizedBox(height: 8),
      ],
    );
  }

  static String _furnishingLabel(String? v) {
    switch (v) {
      case 'furnished': return 'مؤثث';
      case 'semi_furnished': return 'نصف مؤثث';
      case 'unfurnished': return 'غير مؤثث';
      default: return v ?? '—';
    }
  }

  static String _statusLabel(String? v) {
    switch (v) {
      case 'available': return 'متاح';
      case 'rented': return 'مؤجر';
      default: return v ?? '—';
    }
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
  final Property prop;
  const _AmenitiesTab({required this.prop});

  @override
  Widget build(BuildContext context) {
    final sections = <(String, List<String>)>[
      if (prop.kitchenAmenities.isNotEmpty) ('مرافق المطبخ', prop.kitchenAmenities),
      if (prop.bathroomAmenities.isNotEmpty) ('مرافق الحمام', prop.bathroomAmenities),
      if (prop.primaryAmenities.isNotEmpty) ('مرافق أساسية', prop.primaryAmenities),
      if (prop.secondaryAmenities.isNotEmpty) ('خدمات إضافية', prop.secondaryAmenities),
      if (prop.features.isNotEmpty) ('مميزات العقار', prop.features),
    ];
    if (sections.isEmpty && prop.amenities.isNotEmpty) {
      sections.add(('المرافق', prop.amenities));
    }

    // بيانات محلية (بدون تفاصيل من الـ API) — نعرض العينات المعروفة سابقاً.
    if (sections.isEmpty) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        ...sections.map((section) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.black)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: section.$2.map((a) => _AmenityChip(label: AmenityLabels.translate(a))).toList(),
            ),
            const SizedBox(height: 20),
          ],
        )),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _AmenityChip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? Icons.check_circle_outline, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.black)),
          ),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final Property prop;
  final PropertyDetailController ctrl;
  const _ReviewsTab({required this.prop, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    // بيانات محلية (لا يوجد endpoint للتقييمات).
    if (prop.id == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ...SampleData.reviews.map((r) => _ReviewTile(
            name: r.name,
            date: r.date,
            rating: r.rating,
            text: r.comment,
          )),
          _AddReviewButton(onTap: () => _openAddReviewSheet(context)),
        ],
      );
    }

    return Obx(() {
      if (ctrl.reviewsLoading.value) {
        return const SizedBox(
          height: 220,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
          ),
        );
      }
      if (ctrl.reviewsError.value != null && ctrl.reviews.isEmpty) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.cloud_off_outlined, color: AppColors.grey, size: 40),
            const SizedBox(height: 8),
            Text(ctrl.reviewsError.value!, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
            TextButton(
              onPressed: ctrl.loadReviews,
              child: const Text('إعادة المحاولة', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      }
      if (ctrl.reviews.isEmpty) {
        return Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.rate_review_outlined, size: 44, color: AppColors.grey),
            const SizedBox(height: 12),
            const Text('لا توجد تقييمات بعد', style: TextStyle(fontSize: 14, color: AppColors.grey)),
            const SizedBox(height: 4),
            Text('كن أول من يُقيّم هذا العقار', style: TextStyle(fontSize: 12, color: AppColors.grey.withValues(alpha: 0.7))),
            const SizedBox(height: 12),
            _AddReviewButton(onTap: () => _openAddReviewSheet(context)),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _ReviewSummary(ctrl: ctrl),
          const SizedBox(height: 12),
          ...ctrl.reviews.map((r) => _ReviewTile(
            name: r.author,
            date: _formatDate(r.date),
            rating: r.rating,
            text: r.text,
            title: r.title,
            verified: r.verified,
            review: r,
            ctrl: ctrl,
          )),
          if (ctrl.hasMoreReviews)
            Center(
              child: TextButton(
                onPressed: ctrl.loadMoreReviews,
                child: Obx(
                  () => ctrl.reviewsLoadingMore.value
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                      : const Text('تحميل المزيد', style: TextStyle(color: AppColors.primary)),
                ),
              ),
            ),
          const SizedBox(height: 8),
          _AddReviewButton(onTap: () => _openAddReviewSheet(context)),
        ],
      );
    });
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _openAddReviewSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _AddReviewSheet(ctrl: ctrl),
      ),
    );
  }
}

/// ملخص متوسط التقييم وعدد التقييمات.
class _ReviewSummary extends StatelessWidget {
  final PropertyDetailController ctrl;
  const _ReviewSummary({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final avg = ctrl.averageRating.value;
    return Row(
      children: [
        Text(
          avg.toStringAsFixed(1),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (i) => Icon(
                Icons.star,
                size: 18,
                color: i < avg.round() ? Colors.amber : AppColors.fieldBorder,
              )),
            ),
            const SizedBox(height: 2),
            Text('${ctrl.totalReviews.value} تقييم', style: TextStyle(fontSize: 12, color: AppColors.grey.withValues(alpha: 0.8))),
          ],
        ),
      ],
    );
  }
}

/// بطاقة تقييم واحدة.
class _ReviewTile extends StatelessWidget {
  final String name;
  final String date;
  final double rating;
  final String text;
  final String? title;
  final bool verified;
  final PropertyReview? review;
  final PropertyDetailController? ctrl;

  const _ReviewTile({
    required this.name,
    required this.date,
    required this.rating,
    required this.text,
    this.title,
    this.verified = false,
    this.review,
    this.ctrl,
  });

  void _markHelpful() {
    final controller = ctrl;
    final r = review;
    if (controller == null || r == null) return;
    controller.markReviewHelpful(review: r).then((ok) {
      if (!ok) {
        Get.snackbar('تنبيه',
            controller.reviewsError.value ?? 'تعذر التمييز كمفيد',
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(name.isNotEmpty ? name[0] : '؟', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
              ),
              Text(date, style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(rating.toString(), style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              const SizedBox(width: 4),
              ...List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < rating.round() ? Colors.amber : AppColors.fieldBorder)),
              if (verified) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 12, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 2),
                      Text('مُوثّق', style: TextStyle(fontSize: 10, color: Colors.green.shade800)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (title != null && title!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(title!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.black)),
          ],
          const SizedBox(height: 6),
          Text(text, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: AppColors.grey, height: 1.5)),
          if (ctrl != null && review != null) ...[
            const SizedBox(height: 8),
            _HelpfulButton(
              review: review!,
              ctrl: ctrl!,
              onTap: _markHelpful,
            ),
          ],
          const Divider(height: 24),
        ],
      ),
    );
  }
}

/// زر "هذا التقييم مفيد" مع عدّاد الـ helpful.
class _HelpfulButton extends StatelessWidget {
  final PropertyReview review;
  final PropertyDetailController ctrl;
  final VoidCallback onTap;
  const _HelpfulButton({required this.review, required this.ctrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final marked = ctrl.isReviewMarked(review.id);
      final marking = ctrl.markingHelpfulId.value == review.id;
      final color = marked ? AppColors.primary : AppColors.grey;
      return GestureDetector(
        onTap: (marked || marking) ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: marked ? AppColors.primary.withValues(alpha: 0.1) : AppColors.fieldBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: marked ? AppColors.primary : AppColors.fieldBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(marked ? Icons.thumb_up : Icons.thumb_up_outlined, size: 14, color: color),
              const SizedBox(width: 5),
              Text(marked ? 'مفيد' : 'مفيد؟', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
              const SizedBox(width: 6),
              Text('${review.helpful}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey)),
              if (marking) ...[
                const SizedBox(width: 6),
                const SizedBox(
                  width: 12, height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

/// زر فتح فورم إضافة تقييم.
class _AddReviewButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddReviewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.rate_review_outlined, size: 18, color: AppColors.primary),
        label: const Text('أضف تقييمك', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

/// فورم إضافة تقييم (بنطوم شيت).
class _AddReviewSheet extends StatefulWidget {
  final PropertyDetailController ctrl;
  const _AddReviewSheet({required this.ctrl});

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  int _rating = 5;
  bool _submitting = false;
  bool _wouldRecommend = true;
  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      Get.snackbar('تنبيه', 'اكتب نص تقييمك أولاً', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() => _submitting = true);
    final ok = await widget.ctrl.addReview(
      rating: _rating,
      text: text,
      title: _titleController.text,
      wouldRecommend: _wouldRecommend,
    );
    setState(() => _submitting = false);
    if (ok) {
      if (mounted) Navigator.of(context).pop();
      Get.snackbar('تم', 'أُضيف تقييمك بنجاح', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('تعذر الإضافة', widget.ctrl.reviewsError.value ?? 'حدث خطأ ما', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.fieldBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('قيّم العقار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
          const SizedBox(height: 4),
          Text('شارك تجربتك لمساعدة المستأجرين الآخرين',
              style: TextStyle(fontSize: 12, color: AppColors.grey.withValues(alpha: 0.7))),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = starIndex),
                icon: Icon(
                  starIndex <= _rating ? Icons.star : Icons.star_border,
                  color: starIndex <= _rating ? Colors.amber : AppColors.grey,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _titleController,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: 'عنوان التقييم (اختياري)',
              hintTextDirection: TextDirection.rtl,
              filled: true,
              fillColor: AppColors.fieldBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.fieldBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.fieldBorder),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _textController,
            textDirection: TextDirection.rtl,
            maxLines: 4,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'اكتب تجربتك مع العقار...',
              hintTextDirection: TextDirection.rtl,
              filled: true,
              fillColor: AppColors.fieldBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.fieldBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.fieldBorder),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _wouldRecommend ? Colors.green.withValues(alpha: 0.08) : AppColors.fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _wouldRecommend ? Colors.green.withValues(alpha: 0.4) : AppColors.fieldBorder),
            ),
            child: Row(
              children: [
                Icon(
                  _wouldRecommend ? Icons.thumb_up_alt : Icons.thumb_down_alt_outlined,
                  size: 18,
                  color: _wouldRecommend ? const Color(0xFF2E7D32) : AppColors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _wouldRecommend ? 'أنصح بهذا العقار' : 'لا أنصح بهذا العقار',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _wouldRecommend ? const Color(0xFF2E7D32) : AppColors.grey,
                    ),
                  ),
                ),
                Switch(
                  value: _wouldRecommend,
                  onChanged: (v) => setState(() => _wouldRecommend = v),
                  activeThumbColor: const Color(0xFF2E7D32),
                  activeTrackColor: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('نشر التقييم', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  final Property prop;
  const _LocationSection({required this.prop});

  @override
  Widget build(BuildContext context) {
    final fallback = LocationHelper.getFallbackCoords(prop.location.isNotEmpty ? prop.location : prop.city);
    final lat = prop.latitude ?? fallback?.latitude ?? 24.7136;
    final lng = prop.longitude ?? fallback?.longitude ?? 46.6753;
    const hasCoords = true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الموقع و الخريطة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
        const SizedBox(height: 10),
        // ── عنوان الموقع ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.place_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayLocation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    if (hasCoords) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${_fmt(lat)}, ${_fmt(lng)}',
                        style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.7)),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasCoords)
                GestureDetector(
                  onTap: () => _openMaps(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.navigation_outlined, size: 13, color: Colors.white),
                        SizedBox(width: 4),
                        Text('اتجاه', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        // ── الخريطة المضمنة ──
        if (hasCoords) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => PropertyMapScreen(
                  latitude: lat,
                  longitude: lng,
                  address: prop.location,
                ),
              ));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://staticmap.openstreetmap.de/staticmap.php?center=$lat,$lng&zoom=16&size=600x400&maptype=mapnik&markers=$lat,$lng,red-pushpin',
                      fit: BoxFit.cover,
                      loadingBuilder: (c, child, p) => p == null
                          ? child
                          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorBuilder: (c, e, s) => Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map, size: 40, color: AppColors.primary),
                              SizedBox(height: 6),
                              Text('الموقع على الخريطة', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text('اضغط لعرض الخريطة', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String get displayLocation {
    final location = prop.location;
    if (location.isEmpty) return 'الموقع على الخريطة';
    return location;
  }

  String _fmt(double v) => v.toStringAsFixed(5);

  Future<void> _openMaps(BuildContext context) async {
    final lat = prop.latitude;
    final lng = prop.longitude;
    if (lat == null || lng == null) return;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        Get.snackbar('تنبيه', 'تعذر فتح الخرائط', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('تنبيه', 'تعذر فتح الخرائط', snackPosition: SnackPosition.BOTTOM);
    }
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
            onPressed: () {
              if (!AuthController.instance.isLoggedIn) {
                Get.snackbar('تسجيل الدخول', 'يجب تسجيل الدخول أولاً لحجز العقار',
                    snackPosition: SnackPosition.TOP, backgroundColor: AppColors.black);
                Get.toNamed(AppRoutes.login);
                return;
              }
              Get.toNamed(AppRoutes.bookingConfirmation, arguments: prop);
            },
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
