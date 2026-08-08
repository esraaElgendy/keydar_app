import '../../core/constants/app_config.dart';
import '../models/auth_response.dart';
import '../models/customer.dart';
import '../models/customer_statistics.dart';
import '../services/api_client.dart';

/// طبقة الوصول للـ Auth API.
/// كل دالة هنا مسؤولة عن استدعاء endpoint واحد فقط.
class AuthRepository {
  final ApiClient _api = ApiClient.instance;

  /// تسجيل حساب مستأجر (Customer) جديد.
  Future<AuthResponse> customerRegister({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await _api.post(
      AppConfig.customerRegister,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'confirmPassword': password,
        'agreeToTerms': true,
      },
    );
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  /// تسجيل دخول المستأجر (Customer).
  Future<AuthResponse> customerLogin({
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      AppConfig.customerLogin,
      body: {
        'email': email,
        'password': password,
      },
    );
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  /// تسجيل خروج المستأجر.
  Future<void> customerLogout() async {
    await _api.post(AppConfig.customerLogout);
  }

  /// جلب ملف المستأجر (Customer) من الـ API — يتطلب تسجيل دخول.
  Future<Customer> fetchProfile() async {
    final res = await _api.get(AppConfig.customerProfile);
    return _profileFrom(res.data);
  }

  /// تحديث بيانات المستأجر.
  /// يقبل الحقول القابلة للتعديل فقط: الاسم والعائلة والجوال والمدينة والعنوان.
  Future<Customer> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    String? city,
    String? address,
  }) async {
    final res = await _api.put(
      AppConfig.customerProfile,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        if (city != null && city.isNotEmpty) 'city': city,
        if (address != null && address.isNotEmpty) 'address': address,
      },
    );
    return _profileFrom(res.data);
  }

  Customer _profileFrom(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    final profile = data['profile'];
    if (profile is! Map) {
      throw const FormatException('استجابة غير صالحة');
    }
    return Customer.fromJson(Map<String, dynamic>.from(profile));
  }

  /// جلب إحصائيات المستأجر (الحجوزات/النفقات/المفضلة) — يتطلب تسجيل دخول.
  Future<CustomerStatistics> fetchStatistics() async {
    final res = await _api.get(AppConfig.customerStatistics);
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة غير صالحة');
    }
    final stats = data['stats'];
    if (stats is! Map) {
      throw const FormatException('استجابة غير صالحة');
    }
    return CustomerStatistics.fromJson(Map<String, dynamic>.from(stats));
  }
}