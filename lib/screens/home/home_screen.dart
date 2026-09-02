import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/search_controller.dart';
import '../../data/repositories/property_repository.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/cards/property_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AppController());
    final searchCtrl = Get.put(PropertySearchController());

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
                      _SearchBar(ctrl: ctrl, searchCtrl: searchCtrl),
                      const SizedBox(height: 16),
                      _SearchResultsSection(searchCtrl: searchCtrl),
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
  final PropertySearchController searchCtrl;
  const _SearchBar({required this.ctrl, required this.searchCtrl});

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
              onChanged: (v) {
                ctrl.setSearch(v);
                searchCtrl.onSearchChanged(v);
              },
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
        GestureDetector(
          onTap: () => _openFilterSheet(context, searchCtrl),
          child: Obx(() {
            final count = searchCtrl.activeFilterCount;
            return Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: count > 0 ? AppColors.primary : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.tune, color: AppColors.white, size: 22),
                  if (count > 0)
                    Positioned(
                      top: 4, right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text('$count', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  void _openFilterSheet(BuildContext context, PropertySearchController searchCtrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(searchCtrl: searchCtrl),
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

/// قسم نتائج البحث — يظهر فقط عند البحث أو تطبيق الفلاتر.
class _SearchResultsSection extends StatelessWidget {
  final PropertySearchController searchCtrl;
  const _SearchResultsSection({required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasQuery = searchCtrl.searchText.value.isNotEmpty;
      final hasFilters = searchCtrl.hasActiveFilters;
      if (!hasQuery && !hasFilters) return const SizedBox.shrink();

      if (searchCtrl.loading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5)),
        );
      }
      if (searchCtrl.error.value != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, color: AppColors.grey, size: 34),
                const SizedBox(height: 8),
                Text(searchCtrl.error.value!, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
              ],
            ),
          ),
        );
      }
      final items = searchCtrl.results;
      if (items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, color: AppColors.grey, size: 34),
                const SizedBox(height: 8),
                const Text('لا توجد نتائج مطابقة', style: TextStyle(fontSize: 13, color: AppColors.grey)),
              ],
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('نتائج البحث', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
              const Spacer(),
              Text('${searchCtrl.total.value} نتيجة', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 270,
              child: PropertyCard(
                property: p,
                isFavorite: Get.find<AppController>().isFavorite(p),
                onFavoriteTap: () => Get.find<AppController>().toggleFavorite(p),
                onTap: () => Get.toNamed(AppRoutes.propertyDetails, arguments: p),
              ),
            ),
          )),
        ],
      );
    });
  }
}

/// واجهة الفلتر كـ Bottom Sheet — تُظهر خيارات حية من السيرفر.
class _FilterBottomSheet extends StatefulWidget {
  final PropertySearchController searchCtrl;
  const _FilterBottomSheet({required this.searchCtrl});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _city;
  late String? _type;
  late int? _rating;
  late int? _beds;
  late int? _baths;
  late num _minPrice;
  late num _maxPrice;

  @override
  void initState() {
    super.initState();
    _city = widget.searchCtrl.selectedCity.value;
    _type = widget.searchCtrl.selectedType.value;
    _rating = widget.searchCtrl.selectedRating.value;
    _beds = widget.searchCtrl.selectedBedrooms.value;
    _baths = widget.searchCtrl.selectedBathrooms.value;
    _minPrice = widget.searchCtrl.minPrice.value;
    _maxPrice = widget.searchCtrl.maxPrice.value;
  }

  void _apply() {
    widget.searchCtrl.setCity(_city);
    widget.searchCtrl.setType(_type);
    widget.searchCtrl.setRating(_rating);
    widget.searchCtrl.setBedrooms(_beds);
    widget.searchCtrl.setBathrooms(_baths);
    widget.searchCtrl.setPriceRange(_minPrice, _maxPrice);
    Navigator.pop(context);
  }

  void _clear() {
    setState(() {
      _city = null;
      _type = null;
      _rating = null;
      _beds = null;
      _baths = null;
      _minPrice = 0;
      _maxPrice = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = widget.searchCtrl.filtersOptions.value;
    final maxPrice = (filters?.priceRange?.max ?? 1000).toDouble();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── مقبض السحب ──
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
              // ── رأس ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    const Text('فلترة النتائج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
                    const Spacer(),
                    GestureDetector(
                      onTap: _clear,
                      child: const Text('مسح الكل', style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 20, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              // ── المحتوى ──
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // ── المدينة ──
                    const _FilterLabel('المدينة'),
                    const SizedBox(height: 8),
                    _buildCityDropdown(filters),
                    const SizedBox(height: 20),

                    // ── النوع ──
                    const _FilterLabel('نوع العقار'),
                    const SizedBox(height: 8),
                    _buildTypeChips(filters),
                    const SizedBox(height: 20),

                    // ── التقييم ──
                    const _FilterLabel('التصنيف'),
                    const SizedBox(height: 8),
                    _buildRatingChips(filters),
                    const SizedBox(height: 20),

                    // ── غرف النوم ──
                    const _FilterLabel('غرف النوم'),
                    const SizedBox(height: 8),
                    _buildCounterRow(
                      value: _beds,
                      min: 0, max: 10,
                      onChanged: (v) => setState(() => _beds = v),
                    ),
                    const SizedBox(height: 20),

                    // ── دورات المياه ──
                    const _FilterLabel('دورات المياه'),
                    const SizedBox(height: 8),
                    _buildCounterRow(
                      value: _baths,
                      min: 0, max: 10,
                      onChanged: (v) => setState(() => _baths = v),
                    ),
                    const SizedBox(height: 20),

                    // ── نطاق السعر ──
                    _FilterLabel('نطاق السعر (≤ ${_fmtPrice(_maxPrice)})'),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: RangeValues(_minPrice.toDouble(), _maxPrice.toDouble()),
                      min: 0,
                      max: maxPrice,
                      divisions: 20,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.fieldBorder,
                      onChanged: (v) => setState(() { _minPrice = v.start; _maxPrice = v.end; }),
                    ),
                    Row(
                      children: [
                        Text(_fmtPrice(_minPrice), style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.6))),
                        const Spacer(),
                        Text(_fmtPrice(_maxPrice), style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.6))),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              // ── زر التطبيق ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    child: const Text('تطبيق الفلتر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCityDropdown(PropertyFilters? filters) {
    final cities = filters?.cities ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.fieldBorder)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _city,
          isExpanded: true,
          hint: const Text('اختر المدينة', style: TextStyle(fontSize: 13, color: AppColors.grey)),
          items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _city = v),
        ),
      ),
    );
  }

  Widget _buildTypeChips(PropertyFilters? filters) {
    final types = filters?.propertyTypes ?? [];
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: types.map((t) {
        final selected = _type == t;
        return GestureDetector(
          onTap: () => setState(() => _type = selected ? null : t),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: selected ? null : Border.all(color: AppColors.fieldBorder),
            ),
            child: Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? AppColors.white : AppColors.black)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingChips(PropertyFilters? filters) {
    final ratings = filters?.ratings ?? [];
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: ratings.map((r) {
        final selected = _rating == r.stars;
        return GestureDetector(
          onTap: () => setState(() => _rating = selected ? null : r.stars),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: selected ? null : Border.all(color: AppColors.fieldBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(r.stars, (i) => Icon(Icons.star, size: 14, color: selected ? Colors.white : Colors.amber)),
                const SizedBox(width: 4),
                Text(r.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? AppColors.white : AppColors.black)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCounterRow({required int? value, required int min, required int max, required ValueChanged<int> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.fieldBorder)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged((value ?? min) > min ? (value ?? min) - 1 : min),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.fieldBorder)),
              child: const Icon(Icons.remove, size: 18, color: AppColors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Text(value != null ? '$value' : '—', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => onChanged((value ?? min) + 1),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.add, size: 18, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtPrice(num v) {
    if (v <= 0) return '0';
    if (v >= 1000) return '${(v / 1000).toInt()} ألف';
    return v.toInt().toString();
  }
}

class _FilterLabel extends StatelessWidget {
  final String text;
  const _FilterLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black));
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
