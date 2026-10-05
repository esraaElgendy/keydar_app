import 'dart:async';
import 'package:get/get.dart';
import '../data/repositories/property_repository.dart';
import '../models/property.dart';

/// بوابة البحث والفلترة من الباك-إند عبر `GET /properties/search`.
///
/// تدير حالة البحث + الفلاتر + النتائج + التنقيل.
class PropertySearchController extends GetxController {
  final PropertyRepository _repository = PropertyRepository();

  // ── نتائج البحث ──
  final RxList<Property> results = RxList<Property>();
  final RxBool loading = false.obs;
  final RxnString error = RxnString();
  final RxInt total = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  bool get hasMore => currentPage.value < totalPages.value;

  // ── فلاتر محفوظة من السيرفر ──
  final Rxn<PropertyFilters> filtersOptions = Rxn<PropertyFilters>();
  final RxBool filtersLoading = false.obs;

  // ── الفلتر النشط ──
  final RxString searchText = ''.obs;
  final RxnString selectedCity = RxnString();
  final RxnString selectedType = RxnString();
  final RxnInt selectedRating = RxnInt();
  final RxnInt selectedBedrooms = RxnInt();
  final RxnInt selectedBathrooms = RxnInt();
  final Rx<num> minPrice = Rx<num>(0);
  final Rx<num> maxPrice = Rx<num>(0);
  final RxString sortBy = ''.obs;

  Timer? _debounce;

  bool get hasActiveFilters =>
      selectedCity.value != null ||
      selectedType.value != null ||
      selectedRating.value != null ||
      selectedBedrooms.value != null ||
      selectedBathrooms.value != null ||
      minPrice.value > 0 ||
      maxPrice.value > 0;

  int get activeFilterCount {
    int count = 0;
    if (selectedCity.value != null) count++;
    if (selectedType.value != null) count++;
    if (selectedRating.value != null) count++;
    if (selectedBedrooms.value != null) count++;
    if (selectedBathrooms.value != null) count++;
    if (minPrice.value > 0 || maxPrice.value > 0) count++;
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    fetchFilters();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  /// جلب خيارات الفلترة المتاحة من السيرفر.
  Future<void> fetchFilters() async {
    filtersLoading.value = true;
    try {
      filtersOptions.value = await _repository.fetchPropertyFilters();
    } catch (_) {}
    filtersLoading.value = false;
  }

  /// البحث مع debounce (300ms).
  void onSearchChanged(String query) {
    searchText.value = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      search(resetPage: true);
    });
  }

  /// تنفيذ البحث مع جميع الفلاتر النشطة.
  Future<void> search({bool resetPage = false}) async {
    if (resetPage) currentPage.value = 1;
    loading.value = true;
    error.value = null;
    try {
      final result = await _repository.searchProperties(
        search: searchText.value.isNotEmpty ? searchText.value : null,
        city: selectedCity.value,
        type: selectedType.value,
        rating: selectedRating.value,
        bedrooms: selectedBedrooms.value,
        bathrooms: selectedBathrooms.value,
        minPrice: minPrice.value > 0 ? minPrice.value : null,
        maxPrice: maxPrice.value > 0 ? maxPrice.value : null,
        sortBy: sortBy.value.isNotEmpty ? sortBy.value : null,
        page: currentPage.value,
      );
      if (resetPage) {
        results.assignAll(result.properties);
      } else {
        results.addAll(result.properties);
      }
      total.value = result.total;
      totalPages.value = result.pages;
    } catch (e) {
      error.value = 'تعذر البحث، تحقق من اتصالك بالإنترنت';
    }
    loading.value = false;
  }

  /// تحميل الصفحة التالية.
  Future<void> loadMore() async {
    if (!hasMore || loading.value) return;
    currentPage.value++;
    await search();
  }

  /// تطبيق فلتر المدينة.
  void setCity(String? city) {
    selectedCity.value = city;
    search(resetPage: true);
  }

  /// تطبيق فلتر النوع.
  void setType(String? type) {
    selectedType.value = type;
    search(resetPage: true);
  }

  /// تطبيق فلتر التقييم.
  void setRating(int? rating) {
    selectedRating.value = rating;
    search(resetPage: true);
  }

  /// تطبيق فلتر غرف النوم.
  void setBedrooms(int? beds) {
    selectedBedrooms.value = beds;
    search(resetPage: true);
  }

  /// تطبيق فلتر دورات المياه.
  void setBathrooms(int? baths) {
    selectedBathrooms.value = baths;
    search(resetPage: true);
  }

  /// تطبيق نطاق السعر.
  void setPriceRange(num min, num max) {
    minPrice.value = min;
    maxPrice.value = max;
    search(resetPage: true);
  }

  /// مسح جميع الفلاتر والبحث من جديد.
  void clearAll() {
    selectedCity.value = null;
    selectedType.value = null;
    selectedRating.value = null;
    selectedBedrooms.value = null;
    selectedBathrooms.value = null;
    minPrice.value = 0;
    maxPrice.value = 0;
    sortBy.value = '';
    searchText.value = '';
    search(resetPage: true);
  }
}
