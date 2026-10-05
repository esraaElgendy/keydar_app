import '../../core/constants/app_config.dart';
import '../services/api_client.dart';

/// واجهة التفاعل مع مركز المساعدة: الأسئلة الشائعة + إرسال رسالة تواصل.
class HelpRepository {
  final ApiClient _api = ApiClient.instance;

  /// جلب الأسئلة الشائعة حسب التصنيف.
  ///
  /// التصنيفات المتاحة: `booking` · `payment` · `property` · `general`.
  /// يُرجع قائمة فارغة إذا لم توجد أسئلة.
  Future<List<FaqItem>> fetchFAQs({String category = 'general'}) async {
    final res = await _api.get(
      AppConfig.faqs,
      query: {'category': category},
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) return const [];
    final raw = data['faqs'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => FaqItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// إرسال رسالة "تواصل معنا".
  ///
  /// يُرجع [ContactResult] يحتوي على رقم المرجع عند النجاح.
  Future<ContactResult> sendMessage({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    required String subject,
    required String message,
    int? propertyId,
  }) async {
    final body = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'name': '$firstName $lastName',
      'email': email,
      'subject': subject,
      'message': message,
    };
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (propertyId != null) body['propertyId'] = propertyId;

    final res = await _api.post(AppConfig.contactMessage, body: body);
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      return const ContactResult(success: false, message: 'حدث خطأ غير متوقع');
    }
    return ContactResult.fromJson(Map<String, dynamic>.from(data));
  }
}

/// سؤال شائع واحد من الباك-إند.
class FaqItem {
  final int? id;
  final String question;
  final String answer;
  final String? category;

  const FaqItem({
    this.id,
    required this.question,
    required this.answer,
    this.category,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) => FaqItem(
        id: json['id'] as int?,
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
        category: json['category'] as String?,
      );
}

/// نتيجة إرسال رسالة التواصل.
class ContactResult {
  final bool success;
  final String message;
  final String? referenceNumber;

  const ContactResult({
    required this.success,
    required this.message,
    this.referenceNumber,
  });

  factory ContactResult.fromJson(Map<String, dynamic> json) => ContactResult(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        referenceNumber: json['referenceNumber'] as String?,
      );
}
