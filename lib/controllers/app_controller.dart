import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/property_repository.dart';
import '../models/sample_data.dart';
import '../models/property.dart';
import 'auth_controller.dart';

class AppController extends GetxController {
  static const _favoritesKey = 'favorite_properties';

  static AppController get instance => Get.find<AppController>();

  final PropertyRepository _propertyRepo = PropertyRepository();

  final RxList<Car> _allCars = RxList<Car>(SampleData.cars);
  final RxList<Property> favorites = RxList<Property>();
  final RxList<Car> carFavorites = RxList<Car>();

  /// أحدث العقارات القادمة من السيرفر (قسم "أحدث الإيجارات").
  final RxList<Property> latestProperties = RxList<Property>();
  final RxBool latestLoading = false.obs;
  final RxnString latestError = RxnString();

  /// جميع العقارات القادمة من السيرفر (الرئيسية + الاستكشف).
  final RxList<Property> allProperties = RxList<Property>();
  final RxBool allLoading = false.obs;
  final RxnString allError = RxnString();
  final RxList<Property> ownerProperties = RxList<Property>([
    Property(title: 'شقة فاخرة في الرياض', type: 'شقة', location: 'الرياض، العليا', price: '3,200', period: 'شهري', rating: 4.5, reviews: 0, bedrooms: 4, bathrooms: 2, area: 120, image: 'assets/image/building.jpg', description: 'شقة فاخرة في موقع مميز', badge1: 'متاحة'),
    Property(title: 'فيلا مودرن في جدة', type: 'فيلا', location: 'جدة، الشاطئ', price: '5,000', period: 'شهري', rating: 4.5, reviews: 0, bedrooms: 5, bathrooms: 3, area: 250, image: 'assets/image/building.jpg', description: 'فيلا عصرية بإطلالة رائعة', badge1: 'متاحة'),
    Property(title: 'شقة صغيرة في الدمام', type: 'شقة', location: 'الدمام، الحمراء', price: '2,200', period: 'شهري', rating: 4.5, reviews: 0, bedrooms: 3, bathrooms: 2, area: 100, image: 'assets/image/building.jpg', description: 'شقة مريحة', badge1: 'متاحة'),
    Property(title: 'شقة مفروشة في الخبر', type: 'شقة', location: 'الخبر، العقربية', price: '2,800', period: 'شهري', rating: 4.5, reviews: 0, bedrooms: 2, bathrooms: 2, area: 90, image: 'assets/image/building.jpg', description: 'شقة مفروشة بالكامل', badge1: 'مؤجرة'),
    Property(title: 'استوديو في الرياض', type: 'استوديو', location: 'الرياض، حي الملقا', price: '1,500', period: 'شهري', rating: 4.5, reviews: 0, bedrooms: 1, bathrooms: 1, area: 45, image: 'assets/image/building.jpg', description: 'استوديو حديث', badge1: 'متاحة'),
    Property(title: 'دوبلكس في جدة', type: 'دوبلكس', location: 'جدة، أبحر الشمالية', price: '6,500', period: 'شهري', rating: 4.5, reviews: 0, bedrooms: 6, bathrooms: 4, area: 300, image: 'assets/image/building.jpg', description: 'دوبلكس فاخر', badge1: 'متاحة'),
    Property(title: 'شقة تجارية في الرياض', type: 'مكتب', location: 'الرياض، حي المربع', price: '4,000', period: 'شهري', rating: 4.5, reviews: 0, bedrooms: 3, bathrooms: 2, area: 150, image: 'assets/image/building.jpg', description: 'مساحة تجارية', badge1: 'قيد المراجعة'),
  ]);
  final RxString searchQuery = RxString('');
  final RxInt selectedCategoryIndex = 0.obs;

  final RxInt filterType = 0.obs;
  final RxInt filterPayment = 0.obs;
  final RxDouble filterPriceMin = 1000.0.obs;
  final RxDouble filterPriceMax = 500000.0.obs;
  final RxInt filterBedrooms = 2.obs;
  final RxInt filterBathrooms = 2.obs;
  final RxSet<int> filterAmenities = RxSet<int>();

  bool get hasActiveFilters =>
    filterType.value != 0 ||
    filterPayment.value != 0 ||
    filterPriceMin.value != 1000 ||
    filterPriceMax.value != 500000 ||
    filterBedrooms.value != 2 ||
    filterBathrooms.value != 2 ||
    filterAmenities.isNotEmpty;

  List<Property> get filteredProperties {
    var list = allProperties.toList();
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value;
      list = list.where((p) =>
        p.title.contains(q) || p.location.contains(q) || p.type.contains(q)
      ).toList();
    }
    if (hasActiveFilters) {
      list = list.where((p) {
        if (filterType.value > 0) {
          final types = ['', 'شقة', 'مكتب', 'أرض', 'استوديو', 'فيلا'];
          if (p.type != types[filterType.value]) return false;
        }
        if (filterBedrooms.value > 0 && p.bedrooms < filterBedrooms.value) return false;
        if (filterBathrooms.value > 0 && p.bathrooms < filterBathrooms.value) return false;
        return true;
      }).toList();
    }
    return list;
  }

  List<Property> get categoryFilteredProperties {
    final catIndex = selectedCategoryIndex.value;
    if (catIndex == 0) return allProperties;
    final categoryTypes = ['', 'فيلا', 'شقة', 'مكتب'];
    final type = categoryTypes[catIndex];
    return allProperties.where((p) => p.type == type).toList();
  }

  List<Car> get filteredCars {
    if (searchQuery.isEmpty) return _allCars;
    final q = searchQuery.value;
    return _allCars.where((c) =>
      c.name.contains(q) || c.model.contains(q)
    ).toList();
  }

  /// قائمة أحدث الإيجارات مع تطبيق نص البحث الحالي.
  List<Property> get latestFilteredProperties {
    final q = searchQuery.value.trim();
    if (q.isEmpty) return latestProperties;
    return latestProperties
        .where((p) =>
            p.title.contains(q) ||
            p.location.contains(q) ||
            p.type.contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
    fetchLatestProperties();
    fetchAllProperties();
  }

  /// تحميل العقارات المفضلة المحفوظة محلياً عند تشغيل التطبيق.
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_favoritesKey);
      if (raw == null || raw.isEmpty) return;
      final list = (jsonDecode(raw) as List)
          .map((e) => Property.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      favorites.assignAll(list);
    } catch (_) {
      // نبدأ بقائمة فارغة إذا كان الحفظ تالفاً.
    }
  }

  /// حفظ المفضلة محلياً ليستمر وجودها بعد إغلاق التطبيق.
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _favoritesKey,
        jsonEncode(favorites.map((p) => p.toJson()).toList()),
      );
    } catch (_) {
      // فشل الحفظ محلياً لا يوقف التطبيق.
    }
  }

  /// مزامنة المفضلة مع السيرفر: إن كان مسجلاً دخوله نجلب من الـ API
  /// وإلا نعرض المفضلة المحلية فقط.
  Future<void> syncFavorites() async {
    if (!AuthController.instance.isLoggedIn) {
      await _loadFavorites();
      return;
    }
    try {
      final list = await _propertyRepo.fetchFavorites();
      favorites.assignAll(list);
      await _saveFavorites();
    } catch (_) {
      // فشل المزامنة — نعرض المحلية المتاحة.
    }
  }

  /// جلب جميع العقارات من السيرفر.
  /// [silent] يمنع إظهار شاشة التحميل (يُستخدم عند سحب الصفحة للتحديث).
  Future<void> fetchAllProperties({bool silent = false}) async {
    if (!silent) allLoading.value = true;
    allError.value = null;
    try {
      final list = await _propertyRepo.fetchAll();
      allProperties.assignAll(list);
      if (allProperties.isEmpty) {
        allError.value = 'لا توجد عقارات متاحة حالياً';
      }
    } catch (e) {
      allError.value = 'تعذر تحميل العقارات، تحقق من اتصالك بالإنترنت';
    } finally {
      allLoading.value = false;
    }
  }

  void retryAll() => fetchAllProperties();

  /// جلب أحدث العقارات من السيرفر.
  /// [silent] يمنع إظهار شاشة التحميل (يُستخدم عند سحب الصفحة للتحديث).
  Future<void> fetchLatestProperties({int limit = 6, bool silent = false}) async {
    if (!silent) latestLoading.value = true;
    latestError.value = null;
    try {
      final list = await _propertyRepo.fetchLatest(limit: limit);
      latestProperties.assignAll(list);
      if (latestProperties.isEmpty) {
        latestError.value = 'لا توجد عقارات متاحة حالياً';
      }
    } catch (e) {
      latestError.value = 'تعذر تحميل العقارات، تحقق من اتصالك بالإنترنت';
    } finally {
      latestLoading.value = false;
    }
  }

  void retryLatest() => fetchLatestProperties();

  /// قلب حالة التفضيل: يحدّث المفضلة محلياً فوراً ثم يزامن مع السيرفر
  /// إذا كان المستخدم مسجّلاً دخوله.
  void toggleFavorite(Property p) {
    final isFav = favorites.contains(p);
    if (isFav) {
      favorites.remove(p);
    } else {
      favorites.add(p);
    }
    _saveFavorites();
    AuthController.instance.fetchStatistics();

    final id = p.id;
    if (id == null || !AuthController.instance.isLoggedIn) return;

    // مزامنة مع السيرفر بعد التحديث المحلي.
    if (isFav) {
      _propertyRepo.removeFavorite(propertyId: id).then((ok) {
        if (!ok) _revertFavorite(p, addBack: true);
      }).catchError((_) {
        _revertFavorite(p, addBack: true);
      });
    } else {
      _propertyRepo.addFavorite(propertyId: id).then((ok) {
        if (!ok) _revertFavorite(p, addBack: false);
      }).catchError((_) {
        _revertFavorite(p, addBack: false);
      });
    }
  }

  /// إعادة الحالة السابقة إذا فشلت مزامنة المفضلة مع السيرفر.
  void _revertFavorite(Property p, {required bool addBack}) {
    if (addBack) {
      if (!favorites.contains(p)) favorites.add(p);
    } else {
      favorites.remove(p);
    }
    _saveFavorites();
  }

  void toggleCarFavorite(Car c) {
    if (carFavorites.contains(c)) {
      carFavorites.remove(c);
    } else {
      carFavorites.add(c);
    }
  }

  bool isFavorite(Property p) => favorites.contains(p);
  bool isCarFavorite(Car c) => carFavorites.contains(c);

  void setSearch(String q) => searchQuery.value = q;

  void applyFilters({
    required int type,
    required int payment,
    required double priceMin,
    required double priceMax,
    required int bedrooms,
    required int bathrooms,
    required Set<int> amenities,
  }) {
    filterType.value = type;
    filterPayment.value = payment;
    filterPriceMin.value = priceMin;
    filterPriceMax.value = priceMax;
    filterBedrooms.value = bedrooms;
    filterBathrooms.value = bathrooms;
    filterAmenities.clear();
    filterAmenities.addAll(amenities);
  }

  void resetFilters() {
    filterType.value = 0;
    filterPayment.value = 0;
    filterPriceMin.value = 1000;
    filterPriceMax.value = 500000;
    filterBedrooms.value = 2;
    filterBathrooms.value = 2;
    filterAmenities.clear();
  }
}
