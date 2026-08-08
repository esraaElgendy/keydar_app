import 'package:dio/dio.dart';

/// استثناء API يحمل رسالة عربية واضحة تصلح للعرض في الواجهة.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  /// يبني استثناءً من [DioException] مع استخراج رسالة الخطأ
  /// من استجابة Laravel إن وجدت.
  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;
    var message = 'حدث خطأ غير متوقع، حاول مرة أخرى';

    if (data is Map<String, dynamic>) {
      final m = data['message'];
      if (m is String && m.isNotEmpty) {
        message = m;
      } else {
        final errors = data['errors'];
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            message = first.first.toString();
          }
        }
      }
    } else if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      message = 'انتهت مهلة الاتصال، حاول مرة أخرى';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'تعذر الاتصال بالخادم، تأكد من اتصالك بالإنترنت';
    }

    message = _translateServerMessage(message);

    return ApiException(message, statusCode: e.response?.statusCode);
  }

  /// ترجمة رسائل السيرفر الإنجليزية الشائعة إلى عربية واضحة.
  static String _translateServerMessage(String m) {
    final normalized = m.toLowerCase().trim();
    const invalidLogin = {
      'invalid credentials',
      'invalid credentials.',
      'these credentials do not match our records',
      'wrong credentials',
      'email or password is incorrect',
    };
    if (invalidLogin.contains(normalized)) {
      return 'بيانات الدخول غير صحيحة، تحقق من البريد وكلمة المرور أو أنشئ حساباً جديداً';
    }
    if (normalized == 'unauthenticated') {
      return 'انتهت الجلسة، سجّل الدخول مرة أخرى';
    }
    return m;
  }
}