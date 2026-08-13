import 'package:get/get.dart';

import '../core/constants/account_type.dart';
import '../data/models/auth_response.dart';
import '../data/models/customer.dart';
import '../data/models/customer_statistics.dart';
import '../data/models/owner.dart';
import '../data/models/owner_dashboard_stats.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/api_client.dart';
import '../data/services/api_exception.dart';
import '../data/storage/token_storage.dart';
import 'app_controller.dart';

/// يدير حالة المصادقة (تسجيل دخول / تسجيل حساب / خروج).
///
/// الشاشات تستدعي الدوال هنا ولا تتعامل مع الـ API مباشرة.
class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  final AuthRepository _repository = AuthRepository();

  // ---- الحالة (State) ----
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<Customer> customer = Rxn<Customer>();
  final Rxn<Owner> owner = Rxn<Owner>();
  final Rxn<CustomerStatistics> statistics = Rxn<CustomerStatistics>();
  final Rxn<OwnerDashboardStats> ownerStats = Rxn<OwnerDashboardStats>();
  final RxString accountType = RxString(AccountType.searcher);

  /// هل يوجد مستخدم مسجّل دخوله حالياً؟ (مستأجر)
  bool get isLoggedIn => customer.value != null;

  /// هل يوجد مالك مسجّل دخوله حالياً؟
  bool get isOwnerLoggedIn => owner.value != null;

  // ---- تحميل الجلسة عند بدء التطبيق ----
  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await TokenStorage.getToken();
    final data = await TokenStorage.getCustomer();
    final savedType = await TokenStorage.getAccountType();
    final ownerToken = await TokenStorage.getOwnerToken();
    final ownerData = await TokenStorage.getOwner();

    if (savedType != null) {
      accountType.value = savedType;
      AccountType.set(savedType);
    }

    // أولوية جلسة المالك إن وُجدت (لا تتداخل مع جلسة المستأجر).
    if (ownerToken != null && ownerToken.isNotEmpty) {
      ApiClient.instance.setAuthToken(ownerToken);
      if (ownerData != null) {
        owner.value = Owner.fromJson(ownerData);
      }
      if (Get.isRegistered<AppController>()) {
        AppController.instance.fetchOwnerMyProperties();
      }
      return;
    }

    if (token != null && token.isNotEmpty) {
      ApiClient.instance.setAuthToken(token);
      if (data != null) {
        customer.value = Customer.fromJson(data);
      }
      // جلب المفضلة من السيرفر بعد استعادة الجلسة.
      if (Get.isRegistered<AppController>()) {
        AppController.instance.syncFavorites();
      }
    }
  }

  /// جلب ملف المستأجر الحالي من الـ API وتحديث حالة العرض.
  Future<void> fetchProfile() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return;
    try {
      final profile = await _repository.fetchProfile();
      customer.value = profile;
    } catch (_) {
      // صامت: نعرض آخر بيانات متاحة (من تسجيل الدخول).
    }
  }

  /// جلب إحصائيات المستأجر وتحديث الحالة — صامت عند الخطأ.
  Future<void> fetchStatistics() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return;
    try {
      statistics.value = await _repository.fetchStatistics();
    } catch (_) {
      // صامت — نعرض صفر إذا تعذر الجلب.
    }
  }

  /// جلب إحصائيات لوحة تحكم المالك وتحديث الحالة — صامت عند الخطأ.
  Future<void> fetchOwnerStats() async {
    final token = await TokenStorage.getOwnerToken();
    if (token == null || token.isEmpty) return;
    try {
      ownerStats.value = await _repository.fetchOwnerStats();
    } catch (_) {
      // صامت — نعرض آخر بيانات متاحة أو صفر.
    }
  }

  /// تحديث بيانات المستأجر (المعلومات الشخصية) على السيرفر وتحديث الحالة محلياً.
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    String? city,
    String? address,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final updated = await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        city: city,
        address: address,
      );
      final merged = updated.copyWith(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        city: city,
        address: address,
      );
      customer.value = merged;
      await TokenStorage.saveCustomer(merged.toJson());
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (_) {
      errorMessage.value = 'حدث خطأ غير متوقع، حاول مرة أخرى';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديد نوع الحساب المختار (مالك / باحث عن عقار) عند الدخول.
  void setAccountType(String type) {
    accountType.value = type;
    AccountType.set(type);
    TokenStorage.saveAccountType(type);
  }

  String get accountTypeValue => accountType.value;

  /// تسجيل الدخول — يعمل على المستأجر (Customer) حالياً.
  /// [email] قد يكون البريد الإلكتروني أو رقم الجوال.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _runWithErrorHandling(
      request: () => _repository.customerLogin(email: email, password: password),
      fallbackError: 'تعذر تسجيل الدخول',
    );
  }

  /// تسجيل دخول المالك (Owner).
  /// يرجع `true` عند النجاح ويحفظ التوكن وبيانات المالك محلياً.
  Future<bool> ownerLogin({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final res = await _repository.ownerLogin(email: email, password: password);
      if (res.success && res.token.isNotEmpty && res.owner != null) {
        ApiClient.instance.setAuthToken(res.token);
        owner.value = res.owner;
        await TokenStorage.saveOwnerSession(
          token: res.token,
          refreshToken: res.refreshToken,
          owner: res.owner!.toJson(),
        );
        fetchOwnerStats();
        if (Get.isRegistered<AppController>()) {
          AppController.instance.fetchOwnerMyProperties();
        }
        return true;
      }
      errorMessage.value = (res.message != null && res.message!.isNotEmpty)
          ? res.message!
          : 'تعذر تسجيل الدخول، تحقق من البيانات';
      return false;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (_) {
      errorMessage.value = 'حدث خطأ غير متوقع، حاول مرة أخرى';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// إنشاء حساب مستأجر جديد.
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _runWithErrorHandling(
      request: () {
        final parts = fullName.trim().split(RegExp(r'\s+'));
        final firstName = parts.isNotEmpty ? parts.first : fullName;
        final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        return _repository.customerRegister(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          password: password,
        );
      },
      fallbackError: 'تعذر إنشاء الحساب',
    );
  }

  /// تسجيل الخروج: تنظيف التوكن والمحلي (للمستأجر والمالك معاً).
  Future<void> logout() async {
    try {
      if (isOwnerLoggedIn) {
        await _repository.ownerLogout();
      } else {
        await _repository.customerLogout();
      }
    } catch (_) {
      // نتجاهل فشل الخروج من الخادم ونكمل التنظيف محلياً.
    }
    ApiClient.instance.setAuthToken(null);
    customer.value = null;
    owner.value = null;
    ownerStats.value = null;
    statistics.value = null;
    if (Get.isRegistered<AppController>()) {
      AppController.instance.ownerProperties.clear();
    }
    await TokenStorage.clear();
  }

  /// تشغيل طلب مصادقة مع معالجة كاملة للأخطاء.
  /// دائماً ترجع `bool` حتى لو حصل استثناء (شبكة/خادم) — يعرض رسالة ولا يعلّق الشاشة.
  Future<bool> _runWithErrorHandling({
    required Future<AuthResponse> Function() request,
    required String fallbackError,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final res = await request();
      if (res.success && res.token.isNotEmpty) {
        ApiClient.instance.setAuthToken(res.token);
        customer.value = res.customer;
        if (res.customer != null) {
          await TokenStorage.saveSession(
            token: res.token,
            refreshToken: res.refreshToken,
            customer: res.customer!.toJson(),
          );
        }
        // مزامنة المفضلة بعد تسجيل الدخول.
        if (Get.isRegistered<AppController>()) {
          AppController.instance.syncFavorites();
        }
        return true;
      }
      errorMessage.value = (res.message != null && res.message!.isNotEmpty)
          ? res.message!
          : fallbackError;
      return false;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'حدث خطأ غير متوقع، حاول مرة أخرى';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}