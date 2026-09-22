import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/app_controller.dart';
import '../../core/constants/amenity_labels.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/property_repository.dart';
import '../../models/property.dart';
import '../../widgets/video_player_widget.dart';
import '../add_property/upload_images_screen.dart';
import '../edit_property/edit_property_screen.dart';
import '../property_map/property_map_screen.dart';
import '../../core/utils/location_helper.dart';

class OwnerPropertyDetailScreen extends StatefulWidget {
  final Property property;
  const OwnerPropertyDetailScreen({super.key, required this.property});

  @override
  State<OwnerPropertyDetailScreen> createState() => _OwnerPropertyDetailScreenState();
}

class _OwnerPropertyDetailScreenState extends State<OwnerPropertyDetailScreen> {
  late Property _property;
  bool _loading = true;
  bool _saving = false;
  bool _deleting = false;
  bool _changingStatus = false;

  late int _beds;
  late int _baths;
  late int _guests;
  late double _area;

  late List<String> _kitchen;
  late List<String> _bathroom;
  late List<String> _primary;
  late List<String> _secondary;
  late List<String> _features;

  @override
  void initState() {
    super.initState();
    _property = widget.property;
    _sync();
    if (_property.id != null) {
      _loadDetail();
    } else {
      _loading = false;
    }
  }

  void _sync() {
    _beds = _property.bedrooms;
    _baths = _property.bathrooms;
    _guests = _property.guests;
    _area = _property.area;
    _kitchen = List.of(_property.kitchenAmenities);
    _bathroom = List.of(_property.bathroomAmenities);
    _primary = List.of(_property.primaryAmenities);
    _secondary = List.of(_property.secondaryAmenities);
    _features = List.of(_property.features);
  }

  Future<void> _loadDetail() async {
    try {
      final repo = PropertyRepository();
      final fresh = await repo.fetchOwnerPropertyDetail(id: _property.id!);
      Property result = fresh;
      if (_property.id != null) {
        final extraImages = await repo.fetchPropertyImages(_property.id!);
        if (extraImages.isNotEmpty) {
          final merged = <String>{...extraImages, ...fresh.gallery}.toList();
          result = fresh.copyWith(
            gallery: merged,
            imageUrl: fresh.imageUrl ?? extraImages.first,
          );
        }
      }
      if (!mounted) return;
      setState(() {
        _property = result;
        _sync();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openEdit() {
    Get.to(() => EditPropertyScreen(property: _property))?.then((_) {
      _loadDetail();
    });
  }

  /// تغيير حالة العقار (متاح/مؤجرة) عبر الـ Backend ثم تحديث الواجهة.
  Future<void> _changeStatus(String statusKey) async {
    if (_changingStatus) return;
    setState(() => _changingStatus = true);
    try {
      final updated = await PropertyRepository().updateOwnerPropertyStatus(
        id: _property.id!,
        status: statusKey,
      );
      Get.find<AppController>().replaceOwnerProperty(updated);
      if (!mounted) return;
      setState(() {
        _property = updated;
        _sync();
      });
      Get.snackbar('تم التحديث', 'تم تغيير حالة العقار بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: AppColors.white);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('فشل التحديث', 'تعذر تغيير حالة العقار، حاول مرة أخرى.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFC62828),
          colorText: AppColors.white);
    } finally {
      if (mounted) setState(() => _changingStatus = false);
    }
  }

  Future<void> _deleteProperty() async {
    if (_property.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف العقار', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من حذف "${_property.title}"؟\nلا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      await PropertyRepository().deleteOwnerProperty(id: _property.id!);
      Get.find<AppController>().removeOwnerProperty(_property.id!);
      if (!mounted) return;
      Get.back();
      Get.snackbar('تم الحذف', 'تم حذف العقار بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: AppColors.white);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('فشل الحذف', 'تعذر حذف العقار، حاول مرة أخرى.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFC62828),
          colorText: AppColors.white);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updated = await PropertyRepository().updateOwnerProperty(
        id: _property.id!,
        current: _property,
        beds: _beds,
        baths: _baths,
        guests: _guests,
        area: _area,
        amenities: _primary,
        primaryAmenities: _primary,
        secondaryAmenities: _secondary,
        kitchenAmenities: _kitchen,
        bathroomAmenities: _bathroom,
        propertyFeatures: _features,
      );
      Get.find<AppController>().replaceOwnerProperty(updated);
      if (!mounted) return;
      setState(() {
        _property = updated;
        _sync();
      });
      Get.snackbar('تم الحفظ', 'تم تحديث بيانات العقار بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: AppColors.white);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('فشل الحفظ', 'تعذر تحديث العقار، حاول مرة أخرى.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFC62828),
          colorText: AppColors.white);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _dirty => _beds != _property.bedrooms ||
      _baths != _property.bathrooms ||
      _guests != _property.guests ||
      _area != _property.area ||
      !_sameList(_kitchen, _property.kitchenAmenities) ||
      !_sameList(_bathroom, _property.bathroomAmenities) ||
      !_sameList(_primary, _property.primaryAmenities) ||
      !_sameList(_secondary, _property.secondaryAmenities) ||
      !_sameList(_features, _property.features);

  static bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final sa = a.toSet();
    final sb = b.toSet();
    if (sa.length != sb.length) return false;
    return sa.containsAll(sb);
  }

  List<String> _groupFor(String group) {
    switch (group) {
      case 'kitchen':
        return _kitchen;
      case 'bathroom':
        return _bathroom;
      case 'secondary':
        return _secondary;
      case 'features':
        return _features;
      default:
        return _primary;
    }
  }

  void _setGroup(String group, List<String> values) {
    switch (group) {
      case 'kitchen':
        _kitchen = values;
      case 'bathroom':
        _bathroom = values;
      case 'secondary':
        _secondary = values;
      case 'features':
        _features = values;
      default:
        _primary = values;
    }
  }

  /// فتح نافذة لاختيار مرافق جديد وإضافته إلى المجموعة.
  void _addAmenity(String group) {
    final current = _groupFor(group).toSet();
    final available = AmenityLabels.options
        .where((o) => !current.contains(o.$1) && !current.contains(o.$2))
        .toList();
    if (available.isEmpty) {
      Get.snackbar('لا يوجد مرافق اضافية', 'تمت إضافة كل المرافق المتاحة.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.primary, colorText: AppColors.white);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('إضافة مرافق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
              const SizedBox(height: 12),
              Flexible(
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: available.map((o) => ChoiceChip(
                    label: Text(o.$1, style: const TextStyle(fontSize: 12)),
                    selected: false,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    onSelected: (v) {
                      final list = _groupFor(group);
                      if (!list.contains(o.$2) && !list.contains(o.$1)) {
                        list.add(o.$2);
                        _setGroup(group, list);
                        Navigator.pop(ctx);
                        setState(() {});
                      }
                    },
                  )).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward, color: AppColors.black),
            onPressed: () => Get.back(),
          ),
        ),
        title: const Text('تفاصيل العقار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        actions: [
          if (_property.id != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: IconButton(
                tooltip: 'حذف العقار',
                icon: _deleting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC62828)))
                    : const Icon(Icons.delete_outline, color: Color(0xFFC62828)),
                onPressed: _deleting ? null : _deleteProperty,
              ),
            ),
          if (_property.id != null)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: IconButton(
                tooltip: 'تعديل العقار',
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: _openEdit,
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadDetail,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Hero: gallery + status ───
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: _OwnerImageGallery(property: _property, onDeleted: () => _loadDetail()),
                            ),
                            if (_property.videoUrl != null && _property.videoUrl!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                                                  child: VideoPlayerWidget(videoUrl: _property.videoUrl!),
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
                            if (_property.id != null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await Get.to(() => UploadImagesScreen(
                                        propertyId: _property.id!,
                                        propertyTitle: _property.title,
                                      ));
                                      _loadDetail();
                                    },
                                    icon: const Icon(Icons.add_a_photo, size: 18),
                                    label: const Text('إضافة صور / فيديو'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(_property.title,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black),
                                            maxLines: 2, overflow: TextOverflow.ellipsis),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text('${_typeLabel(_property.type)} · ${_furnishingLabel(_property.furnishing)}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                                            maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: AppColors.grey, size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(_property.location,
                                            style: const TextStyle(fontSize: 12, color: AppColors.grey),
                                            maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ),
                                      if (_property.city != null && _property.city!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF2F4F7),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(_property.city!,
                                              style: const TextStyle(fontSize: 11, color: AppColors.darkText, fontWeight: FontWeight.w600)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(_property.description,
                                      style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.darkText),
                                      maxLines: 4, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ─── Status (editable) ───
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('حالة العقار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatusButton(
                                    label: 'متاحة',
                                    icon: Icons.check_circle,
                                    color: const Color(0xFF4CAF50),
                                    selected: _property.badge1 == 'متاحة',
                                    loading: _changingStatus,
                                    onTap: () => _changeStatus('available'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _StatusButton(
                                    label: 'مؤجرة',
                                    icon: Icons.lock,
                                    color: const Color(0xFFFF9800),
                                    selected: _property.badge1 == 'مؤجرة',
                                    loading: _changingStatus,
                                    onTap: () => _changeStatus('rented'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ─── Prices ───
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('الأسعار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: _PriceBox(label: 'يومي', value: _priceFor('daily'))),
                                const SizedBox(width: 10),
                                Expanded(child: _PriceBox(label: 'شهري', value: _priceFor('monthly'))),
                                const SizedBox(width: 10),
                                Expanded(child: _PriceBox(label: 'سنوي', value: _priceFor('yearly'))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ─── Counts (editable) ───
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('المواصفات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: _CountEditor(label: 'غرف النوم', icon: Icons.bed, value: _beds, onChanged: (v) => setState(() => _beds = v))),
                                const SizedBox(width: 10),
                                Expanded(child: _CountEditor(label: 'الحمامات', icon: Icons.bathroom, value: _baths, onChanged: (v) => setState(() => _baths = v))),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: _CountEditor(label: 'الضيوف', icon: Icons.people, value: _guests, onChanged: (v) => setState(() => _guests = v))),
                                const SizedBox(width: 10),
                                Expanded(child: _AreaEditor(label: 'المساحة (م²)', value: _area, onChanged: (v) => setState(() => _area = v))),
                              ],
                            ),
                            if (_dirty) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: _saving ? null : _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.white,
                                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: _saving
                                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
                                      : const Text('حفظ التغييرات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ─── Amenities ───
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              const Text('المرافق والمواصفات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                              const SizedBox(height: 4),
                              const Text('اضغط على أي مرافق لإزالته، أو أضف من القائمة',
                                  style: TextStyle(fontSize: 11, color: AppColors.grey)),
                              const SizedBox(height: 14),
                              _AmenityGroup(
                                title: 'المرافق الأساسية',
                                icon: Icons.star,
                                items: _primary,
                                onToggle: (v) => setState(() => _primary = v),
                                onAdd: () => _addAmenity('primary'),
                              ),
                              _AmenityGroup(
                                title: 'مرافق المطبخ',
                                icon: Icons.kitchen,
                                items: _kitchen,
                                onToggle: (v) => setState(() => _kitchen = v),
                                onAdd: () => _addAmenity('kitchen'),
                              ),
                              _AmenityGroup(
                                title: 'مرافق الحمام',
                                icon: Icons.bathtub,
                                items: _bathroom,
                                onToggle: (v) => setState(() => _bathroom = v),
                                onAdd: () => _addAmenity('bathroom'),
                              ),
                              _AmenityGroup(
                                title: 'خدمات إضافية',
                                icon: Icons.workspace_premium,
                                items: _secondary,
                                onToggle: (v) => setState(() => _secondary = v),
                                onAdd: () => _addAmenity('secondary'),
                              ),
                              _AmenityGroup(
                                title: 'مميزات العقار',
                                icon: Icons.workspace_premium,
                                items: _features,
                                onToggle: (v) => setState(() => _features = v),
                                onAdd: () => _addAmenity('features'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // ─── Additional info ───
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('معلومات إضافية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: _InfoChip(label: 'نوع العقار', value: _typeLabel(_property.type))),
                                const SizedBox(width: 10),
                                Expanded(child: _InfoChip(label: 'التأثيث', value: _furnishingLabel(_property.furnishing))),
                                const SizedBox(width: 10),
                                Expanded(child: _InfoChip(label: 'فترة الإيجار', value: _periodLabel(_property.period))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _InfoChip(label: 'التقييم', value: _property.rating == 0 ? '—' : '${_property.rating} ★')),
                                const SizedBox(width: 10),
                                Expanded(child: _InfoChip(label: 'التعليقات', value: '${_property.reviewsCount}')),
                                const SizedBox(width: 10),
                                Expanded(child: _InfoChip(label: 'المعرف', value: '${_property.id ?? '—'}')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ─── Location & Map ───
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _OwnerLocationSection(property: _property, onEdit: _openEdit),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _priceFor(String key) {
    final prices = _property.prices;
    final v = prices?[key];
    if (v == null) return '—';
    return _fmtNum(v);
  }

  static String _fmtNum(num v) {
    final asInt = v.toInt();
    final s = asInt.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final remaining = s.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }

  String _typeLabel(String type) {
    switch (type.trim()) {
      case 'villa':
        return 'فيلا';
      case 'apartment':
        return 'شقة';
      case 'office':
        return 'مكتب';
      case 'duplex':
        return 'دوبلكس';
      case 'studio':
        return 'استوديو';
      case 'penthouse':
        return 'بنتهاوس';
      case 'commercial':
        return 'تجاري';
      case 'farm':
        return 'مزرعة';
      default:
        return type.isEmpty ? 'عقار' : type;
    }
  }

  String _furnishingLabel(String? f) {
    switch (f) {
      case 'furnished':
        return 'مفروش';
      case 'unfurnished':
        return 'غير مفروش';
      case 'semi-furnished':
        return 'شبه مفروش';
      default:
        return f == null || f.isEmpty ? '—' : f;
    }
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

}

// ───── Owner Image Gallery with delete ─────
class _OwnerImageGallery extends StatefulWidget {
  final Property property;
  final VoidCallback onDeleted;
  const _OwnerImageGallery({required this.property, required this.onDeleted});

  @override
  State<_OwnerImageGallery> createState() => _OwnerImageGalleryState();
}

class _OwnerImageGalleryState extends State<_OwnerImageGallery> {
  late final PageController _pageCtrl;
  int _current = 0;

  List<String> get _images {
    final urls = <String>[];
    if (widget.property.imageUrl != null && widget.property.imageUrl!.isNotEmpty) {
      urls.add(widget.property.imageUrl!);
    }
    for (final g in widget.property.gallery) {
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

  @override
  Widget build(BuildContext context) {
    final imgs = _images;
    if (imgs.isEmpty) {
      return Container(
        height: 190,
        width: double.infinity,
        color: AppColors.darkBlue,
        child: const Icon(Icons.business, color: AppColors.white, size: 60),
      );
    }

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: imgs.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => Image.network(
              imgs[i],
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.darkBlue,
                child: const Icon(Icons.broken_image, color: AppColors.white, size: 40),
              ),
            ),
          ),
          // Status badge
          Positioned(
            top: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(widget.property.badge1).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _statusColor(widget.property.badge1))),
                  const SizedBox(width: 6),
                  Text(widget.property.badge1,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _statusColor(widget.property.badge1))),
                ],
              ),
            ),
          ),
          // Property ID
          if (widget.property.id != null)
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('#${widget.property.id}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.white)),
              ),
            ),
          // Dots indicator
          if (imgs.length > 1)
            Positioned(
              bottom: 8,
              left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imgs.length, (i) => Container(
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
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    if (status.contains('مؤجر') || status.toLowerCase().contains('rented')) return Colors.orange;
    if (status.contains('مراجعة') || status.toLowerCase().contains('review')) return Colors.blue;
    return const Color(0xFF4CAF50);
  }
}

// ───── Status button ─────
class _StatusButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final bool loading;
  final VoidCallback onTap;
  const _StatusButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: selected || loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : AppColors.fieldBorder, width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            if (loading)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary))
            else
              Icon(icon, color: selected ? color : AppColors.grey, size: 20),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: selected ? color : AppColors.grey,
                )),
          ],
        ),
      ),
    );
  }
}

// ───── Price box ─────
class _PriceBox extends StatelessWidget {
  final String label;
  final String value;
  const _PriceBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
          const SizedBox(height: 4),
          Text('$value ر.س', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ───── Editable counter (beds/baths/guests) ─────
class _CountEditor extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;
  const _CountEditor({required this.label, required this.icon, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: AppColors.grey),
              const SizedBox(width: 4),
              Flexible(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepBtn(icon: Icons.remove, onTap: () => onChanged((value - 1).clamp(0, 99))),
                SizedBox(
                  width: 44,
                  child: Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText), textAlign: TextAlign.center),
                ),
                _StepBtn(icon: Icons.add, onTap: () => onChanged((value + 1).clamp(0, 99))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaEditor extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _AreaEditor({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final intVal = value.toInt();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.square_foot, size: 15, color: AppColors.grey),
              const SizedBox(width: 4),
              Flexible(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepBtn(icon: Icons.remove, onTap: () => onChanged(((intVal - 10).clamp(0, 99999)).toDouble())),
                SizedBox(
                  width: 44,
                  child: Text('$intVal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText), textAlign: TextAlign.center),
                ),
                _StepBtn(icon: Icons.add, onTap: () => onChanged(((intVal + 10).clamp(0, 99999)).toDouble())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

// ───── Amenity group ─────
class _AmenityGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final ValueChanged<List<String>> onToggle;
  final VoidCallback onAdd;
  const _AmenityGroup({
    required this.title,
    required this.icon,
    required this.items,
    required this.onToggle,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              const Spacer(),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: AppColors.primary),
                      SizedBox(width: 2),
                      Text('إضافة', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text('لا توجد مرافق مضافة بعد', style: TextStyle(fontSize: 12, color: AppColors.grey))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((a) => _AmenityChip(label: a, onRemove: () {
                onToggle(items.where((x) => x != a).toList());
              })).toList(),
            ),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _AmenityChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final value = AmenityLabels.apiValueForLabel(label) ?? label;
    return Container(
      padding: const EdgeInsets.only(left: 6, right: 10, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          Text(AmenityLabels.translate(value),
              style: const TextStyle(fontSize: 12, color: AppColors.primary)),
        ],
      ),
    );
  }
}

// ───── Info chip ─────
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ───── Owner Location & Map Section ─────
class _OwnerLocationSection extends StatelessWidget {
  final Property property;
  final VoidCallback onEdit;
  const _OwnerLocationSection({required this.property, required this.onEdit});

  String get _staticMapUrl {
    final lat = property.latitude!;
    final lng = property.longitude!;
    return 'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=$lat,$lng&zoom=16&size=600x400&maptype=mapnik'
        '&markers=$lat,$lng,red-pushpin';
  }

  Future<void> _openGoogleMaps() async {
    final lat = property.latitude!;
    final lng = property.longitude!;
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar('تنبيه', 'تعذر فتح خرائط جوجل', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = property.latitude;
    final lng = property.longitude;
    final hasCoords = lat != null && lng != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── العنوان ──
          Row(
            children: [
              const Icon(Icons.map_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('الموقع والخريطة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
              const Spacer(),
              if (!hasCoords)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_location_alt_outlined, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('تحديد الموقع', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          if (!hasCoords) ...[
            // ── لا يوجد إحداثيات ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.location_off_outlined, size: 40, color: Color(0xFFF9A825)),
                  const SizedBox(height: 10),
                  const Text(
                    'لم يتم تحديد موقع العقار على الخريطة',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'اضغط على "تحديد الموقع" أعلاه لإضافة الإحداثيات\nوتمكين العملاء من العثور على العقار بسهولة',
                    style: TextStyle(fontSize: 12, color: AppColors.grey.withValues(alpha: 0.8), height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_location_alt, size: 18, color: Colors.white),
                      label: const Text('إضافة موقع العقار',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // ── عنوان الموقع + إحداثيات ──
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
                          property.location.isEmpty ? 'الموقع على الخريطة' : property.location,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                          style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _openGoogleMaps,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_outlined, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('اتجاهات', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // ── الخريطة المصغرة (اضغط لفتح الخريطة الكاملة) ──
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PropertyMapScreen(
                    latitude: lat,
                    longitude: lng,
                    address: property.location,
                  ),
                ));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _staticMapUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (c, child, p) => p == null
                            ? child
                            : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                        errorBuilder: (c, e, s) => Container(
                          color: const Color(0xFFF5F5F5),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map, size: 40, color: AppColors.primary),
                                SizedBox(height: 6),
                                Text('موقع العقار', style: TextStyle(color: AppColors.grey, fontSize: 12)),
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
                              Text('اضغط لعرض الخريطة كاملة',
                                  style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // ── أزرار الإجراءات ──
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openGoogleMaps,
                    icon: const Icon(Icons.directions_outlined, size: 16, color: Colors.white),
                    label: const Text('الاتجاهات',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_location_alt_outlined, size: 16, color: AppColors.primary),
                    label: const Text('تعديل الموقع',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
