import 'customer.dart';

/// الاستجابة الموحّدة لعمليات المصادقة (login / register).
///
/// مثال login:
/// { success, token, refreshToken, expiresIn, customer }
/// مثال register:
/// { success, token, message, customer }
class AuthResponse {
  final bool success;
  final String token;
  final String? refreshToken;
  final int? expiresIn;
  final String? message;
  final Customer? customer;

  const AuthResponse({
    required this.success,
    required this.token,
    this.refreshToken,
    this.expiresIn,
    this.message,
    this.customer,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
      message: json['message'] as String?,
      customer: json['customer'] is Map<String, dynamic>
          ? Customer.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
    );
  }
}