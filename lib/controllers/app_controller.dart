import 'package:get/get.dart';
import '../models/sample_data.dart';
import '../models/property.dart';

class AppController extends GetxController {
  final RxList<Property> _allProperties = RxList<Property>(SampleData.properties);
  final RxList<Car> _allCars = RxList<Car>(SampleData.cars);
  final RxList<Property> favorites = RxList<Property>();
  final RxList<Car> carFavorites = RxList<Car>();
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
