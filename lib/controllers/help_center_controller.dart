import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/repositories/help_repository.dart';

/// حالة شاشة مركز المساعدة: تبويب الأسئلة الشائعة + نموذج التواصل.
class HelpCenterController extends GetxController {
  final HelpRepository _repository = HelpRepository();

  // ── تبويب نشط: 0 = الأسئلة الشائعة، 1 = تواصل معنا ──
  final RxInt activeTab = 0.obs;

  // ── الأسئلة الشائعة ──
  final RxList<FaqItem> faqs = RxList<FaqItem>();
  final RxBool faqLoading = false.obs;
  final RxString faqCategory = 'general'.obs;
  final RxInt expandedFaqIndex = (-1).obs;

  // ── نموذج التواصل ──
  final firstNameCtl = TextEditingController();
  final lastNameCtl = TextEditingController();
  final emailCtl = TextEditingController();
  final phoneCtl = TextEditingController();
  final subjectCtl = TextEditingController();
  final messageCtl = TextEditingController();

  final RxBool sending = false.obs;
  final RxnString sendError = RxnString();
  final Rxn<ContactResult> sendResult = Rxn<ContactResult>();

  // ── ملفات اختيارية من الباك-إند ──
  static const faqCategories = [
    {'key': 'general', 'label': 'عام', 'icon': Icons.help_outline},
    {'key': 'booking', 'label': 'الحجز', 'icon': Icons.calendar_today},
    {'key': 'payment', 'label': 'الدفع', 'icon': Icons.payment},
    {'key': 'property', 'label': 'العقارات', 'icon': Icons.home_outlined},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchFAQs();
  }

  @override
  void onClose() {
    firstNameCtl.dispose();
    lastNameCtl.dispose();
    emailCtl.dispose();
    phoneCtl.dispose();
    subjectCtl.dispose();
    messageCtl.dispose();
    super.onClose();
  }

  void setTab(int index) {
    activeTab.value = index;
  }

  void setFaqCategory(String category) {
    faqCategory.value = category;
    expandedFaqIndex.value = -1;
    fetchFAQs();
  }

  void toggleFaq(int index) {
    expandedFaqIndex.value = expandedFaqIndex.value == index ? -1 : index;
  }

  /// جلب الأسئلة الشائعة حسب التصنيف.
  Future<void> fetchFAQs() async {
    faqLoading.value = true;
    try {
      faqs.assignAll(await _repository.fetchFAQs(category: faqCategory.value));
    } catch (_) {}
    faqLoading.value = false;
  }

  /// إرسال رسالة التواصل.
  Future<void> sendMessage() async {
    // تحقق من الحقول الأساسية
    if (firstNameCtl.text.trim().isEmpty ||
        lastNameCtl.text.trim().isEmpty ||
        emailCtl.text.trim().isEmpty ||
        subjectCtl.text.trim().isEmpty ||
        messageCtl.text.trim().isEmpty) {
      sendError.value = 'يرجى ملء جميع الحقول المطلوبة';
      return;
    }

    sending.value = true;
    sendError.value = null;
    sendResult.value = null;

    try {
      final result = await _repository.sendMessage(
        firstName: firstNameCtl.text.trim(),
        lastName: lastNameCtl.text.trim(),
        email: emailCtl.text.trim(),
        phone: phoneCtl.text.trim().isNotEmpty ? phoneCtl.text.trim() : null,
        subject: subjectCtl.text.trim(),
        message: messageCtl.text.trim(),
      );
      sendResult.value = result;
      if (result.success) _clearForm();
    } catch (e) {
      sendError.value = 'تعذر إرسال الرسالة، تحقق من اتصالك بالإنترنت';
    }

    sending.value = false;
  }

  void _clearForm() {
    firstNameCtl.clear();
    lastNameCtl.clear();
    emailCtl.clear();
    phoneCtl.clear();
    subjectCtl.clear();
    messageCtl.clear();
  }

  void resetResult() {
    sendResult.value = null;
    sendError.value = null;
  }
}
