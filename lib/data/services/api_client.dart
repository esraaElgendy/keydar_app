import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_config.dart';
import 'api_exception.dart';

/// عميل HTTP موحّد مبني على [Dio].
///
/// كل الطبقات (repositories) تستخدم هذا العميل فقط،
/// فلو تغيّر السيرفر أو طريقة الـ auth تُعدّل هنا فقط.
class ApiClient {
  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio dio;

  /// إضافة توكن للمصادقة على كل الطلبات بعد ذلك.
  void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      return await dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    if (kDebugMode) {
      debugPrint('API ▶ POST $path');
      debugPrint('API ▶ body: $body');
    }
    try {
      final res = await dio.post(path, data: body);
      if (kDebugMode) debugPrint('API ◀ status=${res.statusCode} body=${res.data}');
      return res;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
            'API ✖ status=${e.response?.statusCode} path=$path body=${e.response?.data}');
      }
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      return await dio.put(path, data: body);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<dynamic>> delete(String path) async {
    try {
      return await dio.delete(path);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}