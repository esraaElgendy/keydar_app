import 'owner.dart';

/// الاستجابة الخاصة بتسجيل دخول المالك (`POST /auth/owner-login`).
///
/// مثال:
/// { success, token, refreshToken, expiresIn, owner }
class OwnerAuthResponse {
  final bool success;
  final String token;
  final String? refreshToken;
  final int? expiresIn;
  final String? message;
  final Owner? owner;

  const OwnerAuthResponse({
    required this.success,
    required this.token,
    this.refreshToken,
    this.expiresIn,
    this.message,
    this.owner,
  });

  factory OwnerAuthResponse.fromJson(Map<String, dynamic> json) {
    return OwnerAuthResponse(
      success: json['success'] as bool? ?? false,
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
      message: json['message'] as String?,
      owner: json['owner'] is Map<String, dynamic>
          ? Owner.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
    );
  }
}