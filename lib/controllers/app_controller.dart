import 'package:get/get.dart';
import '../models/sample_data.dart';
import '../models/property.dart';

class AppController extends GetxController {
  final RxList<Property> _allProperties = RxList<Property>(SampleData.properties);
  final RxList<Car> _allCars = RxList<Car>(SampleData.cars);
  final RxList<Property> favorites = RxList<Property>();
  final RxList<Car> carFavorites = RxList<Car>();
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
    var list = _allProperties.toList();
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
    if (catIndex == 0) return _allProperties;
    final categoryTypes = ['', 'فيلا', 'شقة', 'مكتب'];
    final type = categoryTypes[catIndex];
    return _allProperties.where((p) => p.type == type).toList();
  }

  List<Car> get filteredCars {
    if (searchQuery.isEmpty) return _allCars;
    final q = searchQuery.value;
    return _allCars.where((c) =>
      c.name.contains(q) || c.model.contains(q)
    ).toList();
  }

  void toggleFavorite(Property p) {
    if (favorites.contains(p)) {
      favorites.remove(p);
    } else {
      favorites.add(p);
    }
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
