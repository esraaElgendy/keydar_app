import 'package:get/get.dart';

import '../core/constants/account_type.dart';
import '../data/models/auth_response.dart';
import '../data/models/customer.dart';
import '../data/models/customer_statistics.dart';
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
  final Rxn<CustomerStatistics> statistics = Rxn<CustomerStatistics>();
  final RxString accountType = RxString(AccountType.searcher);

  /// هل يوجد مستخدم مسجّل دخوله حالياً؟
  bool get isLoggedIn => customer.value != null;

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

    if (savedType != null) {
      accountType.value = savedType;
      AccountType.set(savedType);
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

  /// تسجيل الخروج: تنظيف التوكن والمحلي.
  Future<void> logout() async {
    try {
      await _repository.customerLogout();
    } catch (_) {
      // نتجاهل فشل الخروج من الخادم ونكمل التنظيف محلياً.
    }
    ApiClient.instance.setAuthToken(null);
    customer.value = null;
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