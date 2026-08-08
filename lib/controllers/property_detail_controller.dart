import 'package:get/get.dart';
import '../data/models/review.dart';
import '../data/repositories/property_repository.dart';
import '../models/property.dart';
import 'auth_controller.dart';

/// يدير جلب تفاصيل عقار واحد وتقييماته وعرضها في شاشة التفاصيل.
class PropertyDetailController extends GetxController {
  final PropertyRepository _repository = PropertyRepository();

  final Rx<Property?> property = Rxn<Property>();
  final RxBool loading = false.obs;
  final RxnString errorMessage = RxnString();

  // ---- تقييمات العقار ----
  final RxList<PropertyReview> reviews = RxList<PropertyReview>();
  final RxBool reviewsLoading = false.obs;
  final RxBool reviewsLoadingMore = false.obs;
  final RxnString reviewsError = RxnString();
  final RxDouble averageRating = 0.0.obs;
  final RxInt totalReviews = 0.obs;
  bool get hasMoreReviews => _reviewsLoaded && _reviewsPage < _reviewsTotalPages;

  bool _reviewsLoaded = false;
  int _reviewsPage = 1;
  int _reviewsTotalPages = 1;

  /// العقار المبدئي (المار عبر الروت) للعرض الفوري حتى يصل الـ detail.
  Property get initial => property.value!;

  Future<void> load({required Property fromList}) async {
    final id = fromList.id;
    if (id == null) {
      // بيانات محلية — لا يوجد endpoint لها.
      property.value = fromList;
      return;
    }
    // نعرض فوراً بيانات الكارت ونحدّثها بالتفاصيل لما تدخل.
    property.value = fromList;
    loading.value = true;
    errorMessage.value = null;
    try {
      final detail = await _repository.fetchDetail(id: id);
      property.value = detail;
      loadReviews(); // نبدأ تحميل التقييمات هنا أيضاً.
    } catch (e) {
      errorMessage.value = 'تعذر تحميل التفاصيل، تحقق من اتصالك بالإنترنت';
    } finally {
      loading.value = false;
    }
  }

  /// جلب الصفحة الأولى من التقييمات.
  Future<void> loadReviews() async {
    final id = property.value?.id;
    if (id == null) return;
    reviewsLoading.value = true;
    reviewsError.value = null;
    try {
      final page = await _repository.fetchReviews(propertyId: id);
      reviews.assignAll(page.reviews);
      _reviewsPage = page.page;
      _reviewsTotalPages = page.pages;
      averageRating.value = page.averageRating;
      totalReviews.value = page.totalReviews;
      _reviewsLoaded = true;
    } catch (e) {
      reviewsError.value = 'تعذر تحميل التقييمات';
    } finally {
      reviewsLoading.value = false;
    }
  }

  /// تحميل الصفحة التالية من التقييمات.
  Future<void> loadMoreReviews() async {
    if (reviewsLoadingMore.value || !hasMoreReviews) return;
    final id = property.value?.id;
    if (id == null) return;
    reviewsLoadingMore.value = true;
    try {
      final page = await _repository.fetchReviews(propertyId: id, page: _reviewsPage + 1);
      reviews.addAll(page.reviews);
      _reviewsPage = page.page;
      _reviewsTotalPages = page.pages;
      averageRating.value = page.averageRating;
      totalReviews.value = page.totalReviews;
    } finally {
      reviewsLoadingMore.value = false;
    }
  }

  /// إضافة تقييم جديد. يتطلب تسجيل دخول.
  /// يرجع `true` عند النجاح بعد تحديث القائمة.
  Future<bool> addReview({
    required int rating,
    required String text,
    String? title,
    bool wouldRecommend = false,
  }) async {
    final id = property.value?.id;
    if (id == null) return false;
    if (!AuthController.instance.isLoggedIn) {
      reviewsError.value = 'سجّل الدخول أولاً لإضافة تقييم';
      return false;
    }
    try {
      await _repository.addReview(
        propertyId: id,
        rating: rating,
        text: text,
        title: title,
        wouldRecommend: wouldRecommend,
      );
      await loadReviews();
      return true;
    } catch (e) {
      reviewsError.value = 'تعذر إضافة التقييم، حاول مرة أخرى';
      return false;
    }
  }

  /// تمييز تقييم كمفيد (يتطلب تسجيل دخول). يحدّث العداد محلياً.
  /// كل مستخدم يميِّز التقييم مرة واحدة خلال الجلسة.
  final Set<int> _markedHelpful = {};
  final RxInt markingHelpfulId = 0.obs;

  bool isReviewMarked(int reviewId) => _markedHelpful.contains(reviewId);

  Future<bool> markReviewHelpful({required PropertyReview review}) async {
    final id = property.value?.id;
    if (id == null || _markedHelpful.contains(review.id)) return false;
    if (!AuthController.instance.isLoggedIn) {
      reviewsError.value = 'سجّل الدخول أولاً لتمييز التقييم كمفيد';
      return false;
    }
    markingHelpfulId.value = review.id;
    try {
      final count = await _repository.markReviewHelpful(
        propertyId: id,
        reviewId: review.id,
      );
      _markedHelpful.add(review.id);
      final index = reviews.indexWhere((r) => r.id == review.id);
      if (index >= 0) {
        reviews[index] = reviews[index].copyWith(helpful: count);
      }
      return true;
    } catch (e) {
      reviewsError.value = 'تعذر التمييز، حاول مرة أخرى';
      return false;
    } finally {
      markingHelpfulId.value = 0;
    }
  }
}