import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// حفظ وقراءة جلسة المستخدم محلياً.
///
/// يخزّن: التوكن، التوكن المتجدّد، بيانات المستخدم، ونوع الحساب.
class TokenStorage {
  TokenStorage._();

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _customerKey = 'auth_customer_data';
  static const _accountTypeKey = 'auth_account_type';

  static Future<void> saveSession({
    required String token,
    String? refreshToken,
    required Map<String, dynamic> customer,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
    await prefs.setString(_customerKey, jsonEncode(customer));
  }

  /// تحديث بيانات المستخدم المحفوظة فقط (بدون تغيير التوكن).
  static Future<void> saveCustomer(Map<String, dynamic> customer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customerKey, jsonEncode(customer));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<Map<String, dynamic>?> getCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customerKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> saveAccountType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountTypeKey, type);
  }

  static Future<String?> getAccountType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accountTypeKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_customerKey);
    await prefs.remove(_accountTypeKey);
  }
}