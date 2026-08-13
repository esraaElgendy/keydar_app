import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
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
import '../../widgets/property_image.dart';

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
        if (prop == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return Column(
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
                          _PropertyInfo(prop: prop, ctrl: _ctrl),
                          const SizedBox(height: 20),
                          _DetailsTabs(tabController: _tabController),
                          SizedBox(
                            height: 420,
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
                itemBuilder: (_, i) {
                  final isMore = i == 5 && prop.gallery.length > 6;
                  return Container(
                    width: 60,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
                    ),
                    child: isMore
                        ? Container(
                            color: AppColors.black.withValues(alpha: 0.35),
                            child: Center(
                              child: Text(
                                '+${prop.gallery.length - 5}',
                                style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : Image.network(
                            prop.gallery.length > i ? prop.gallery[i] : '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.black.withValues(alpha: 0.3),
                            ),
                          ),
                  );
                },
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
  final PropertyDetailController ctrl;
  const _PropertyInfo({required this.prop, required this.ctrl});

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
            Text(prop.period.isNotEmpty ? prop.period : '/ شهرياً', style: const TextStyle(fontSize: 13, color: AppColors.grey)),
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
            Expanded(child: _SpecBox(icon: Icons.layers_outlined, label: prop.floor != null ? '${prop.floor} ' : 'الخامس الدور')),
            const SizedBox(width: 8),
            Expanded(child: _SpecBox(icon: Icons.straighten, label: '${prop.area.floorToDouble()} المساحة')),
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
      width: (MediaQuery.of(context).size.width - 68) / 4,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        children: [
          Icon(icon ?? Icons.check_circle_outline, color: AppColors.primary, size: 22),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.grey)),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 13, color: Color(0xFF2E7D32)),
                    Text('مُوثّق', style: TextStyle(fontSize: 10, color: Colors.green.shade800)),
                  ],
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
    final lat = prop.latitude;
    final lng = prop.longitude;
    final hasCoords = lat != null && lng != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الموقع و الخريطة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.place_outlined, color: AppColors.primary, size: 40),
              const SizedBox(height: 8),
              Text(
                displayLocation,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                hasCoords ? '${_fmt(lat)}, ${_fmt(lng)}' : displayLocation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.grey.withValues(alpha: 0.7),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (hasCoords) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _openMaps(context),
                  icon: const Icon(Icons.navigation_outlined, size: 16, color: Colors.white),
                  label: const Text('فتح في الخرائط', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ),
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
