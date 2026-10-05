import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/help_center_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/help_repository.dart';

/// شاشة مركز المساعدة — تبويبان:
/// 1. الأسئلة الشائعة (_accordion)
/// 2. تواصل معنا (نموذج)
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HelpCenterController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── رأس الشاشة ──
            _buildHeader(context),

            // ── شريط التبويب ──
            _buildTabBar(ctrl),

            // ── المحتوى ──
            Expanded(
              child: Obx(() => ctrl.activeTab.value == 0
                  ? _FaqTab(ctrl: ctrl)
                  : _ContactTab(ctrl: ctrl)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_forward, color: AppColors.black, size: 24),
          ),
          const Expanded(
            child: Center(
              child: Text('مركز المساعدة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black)),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildTabBar(HelpCenterController ctrl) {
    return Obx(() {
      final tab = ctrl.activeTab.value;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Row(
          children: [
            _TabButton(
              label: 'الأسئلة الشائعة',
              icon: Icons.help_outline,
              selected: tab == 0,
              onTap: () => ctrl.setTab(0),
            ),
            _TabButton(
              label: 'تواصل معنا',
              icon: Icons.chat_bubble_outline,
              selected: tab == 1,
              onTap: () => ctrl.setTab(1),
            ),
          ],
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════
//  تبويب الأسئلة الشائعة
// ═══════════════════════════════════════════════

class _FaqTab extends StatelessWidget {
  final HelpCenterController ctrl;
  const _FaqTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── فلاتر التصنيف ──
        SizedBox(
          height: 48,
          child: Obx(() {
            final active = ctrl.faqCategory.value;
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: HelpCenterController.faqCategories.length,
              separatorBuilder: (context, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = HelpCenterController.faqCategories[i];
                final isSelected = active == cat['key'];
                return GestureDetector(
                  onTap: () => ctrl.setFaqCategory(cat['key'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? null : Border.all(color: AppColors.fieldBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat['icon'] as IconData, size: 16, color: isSelected ? AppColors.white : AppColors.grey),
                        const SizedBox(width: 6),
                        Text(cat['label'] as String,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? AppColors.white : AppColors.black)),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),

        // ── قائمة الأسئلة ──
        Expanded(
          child: Obx(() {
            if (ctrl.faqLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5));
            }
            if (ctrl.faqs.isEmpty) {
              return _EmptyFaq(category: ctrl.faqCategory.value);
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: ctrl.faqs.length,
              separatorBuilder: (context, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _FaqCard(
                item: ctrl.faqs[i],
                expanded: ctrl.expandedFaqIndex.value == i,
                onTap: () => ctrl.toggleFaq(i),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// بطاقة سؤال شائع مع Accordion.
class _FaqCard extends StatelessWidget {
  final FaqItem item;
  final bool expanded;
  final VoidCallback onTap;

  const _FaqCard({required this.item, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: expanded ? AppColors.primary.withValues(alpha: 0.3) : AppColors.fieldBorder),
          boxShadow: expanded
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.help_outline, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.question,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black)),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.keyboard_arrow_down, color: AppColors.grey.withValues(alpha: 0.5), size: 20),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 14, right: 44),
                child: Text(item.answer,
                    style: TextStyle(fontSize: 13, color: AppColors.grey.withValues(alpha: 0.8), height: 1.7)),
              ),
              crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

/// حالة فارغة عند عدم وجود أسئلة.
class _EmptyFaq extends StatelessWidget {
  final String category;
  const _EmptyFaq({required this.category});

  @override
  Widget build(BuildContext context) {
    final catName = HelpCenterController.faqCategories
        .firstWhereOrNull((c) => c['key'] == category)?['label'] ?? 'هذا التصنيف';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.question_answer_outlined, size: 36, color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20),
            Text('لا توجد أسئلة في تصنيف "$catName"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.black)),
            const SizedBox(height: 8),
            Text('يمكنك التواصل معنا مباشرة لمساعدتك',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.grey.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  تبويب تواصل معنا
// ═══════════════════════════════════════════════

class _ContactTab extends StatelessWidget {
  final HelpCenterController ctrl;
  const _ContactTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── بطاقة معلومات التواصل ──
          _ContactInfoCard(),
          const SizedBox(height: 24),

          // ── نموذج إرسال رسالة ──
          Text('أرسل لنا رسالة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
          const SizedBox(height: 4),
          Text('academy.rental@gmail.com',
              style: TextStyle(fontSize: 12, color: AppColors.grey.withValues(alpha: 0.5))),
          const SizedBox(height: 16),

          // ── الاسم الأول + اسم العائلة ──
          Row(
            children: [
              Expanded(child: _Field(label: 'الاسم الأول', controller: ctrl.firstNameCtl, hint: 'أحمد')),
              const SizedBox(width: 12),
              Expanded(child: _Field(label: 'اسم العائلة', controller: ctrl.lastNameCtl, hint: 'محمد')),
            ],
          ),
          const SizedBox(height: 14),

          // ── البريد الإلكتروني ──
          _Field(label: 'البريد الإلكتروني', controller: ctrl.emailCtl, hint: 'ahmed@example.com', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 14),

          // ── رقم الهاتف (اختياري) ──
          _Field(label: 'رقم الهاتف (اختياري)', controller: ctrl.phoneCtl, hint: '+966 5XX XXX XXXX', keyboardType: TextInputType.phone),
          const SizedBox(height: 14),

          // ── عنوان الرسالة ──
          _Field(label: 'عنوان الرسالة', controller: ctrl.subjectCtl, hint: 'استفسار عن الحجز'),
          const SizedBox(height: 14),

          // ── نص الرسالة ──
          _Field(label: 'نص الرسالة', controller: ctrl.messageCtl, hint: 'اكتب رسالتك هنا...', maxLines: 5),
          const SizedBox(height: 20),

          // ── رسالة النجاح/الخطأ ──
          _SendResultBanner(ctrl: ctrl),
          const SizedBox(height: 12),

          // ── زر الإرسال ──
          Obx(() {
            final isSending = ctrl.sending.value;
            return SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: isSending ? null : () => ctrl.sendMessage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: isSending
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5))
                    : const Text('إرسال الرسالة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            );
          }),
          const SizedBox(height: 16),

          // ── ساعات العمل ──
          Center(
            child: Text(
              'ساعات العمل: الأحد — الخميس\n9:00 صباحاً — 6:00 مساءً',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.grey.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  مكونات مشتركة
// ═══════════════════════════════════════════════

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? AppColors.white : AppColors.grey),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? AppColors.white : AppColors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const Icon(Icons.support_agent, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('هل تحتاج مساعدة؟',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('فريقنا جاهز لمساعدتك في أي وقت',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Text(label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 12 : 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintTextDirection: TextDirection.rtl,
              hintStyle: TextStyle(fontSize: 14, color: AppColors.grey.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SendResultBanner extends StatelessWidget {
  final HelpCenterController ctrl;
  const _SendResultBanner({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = ctrl.sendError.value;
      final result = ctrl.sendResult.value;

      if (error != null) {
        return _Banner(
          icon: Icons.error_outline,
          color: Colors.red,
          bgColor: const Color(0xFFFFF5F5),
          text: error,
          onDismiss: () => ctrl.resetResult(),
        );
      }
      if (result != null) {
        return _Banner(
          icon: result.success ? Icons.check_circle_outline : Icons.info_outline,
          color: result.success ? const Color(0xFF2E7D32) : AppColors.primary,
          bgColor: result.success ? const Color(0xFFE8F5E9) : AppColors.primary.withValues(alpha: 0.08),
          text: result.success
              ? 'تم إرسال رسالتك بنجاح${result.referenceNumber != null ? '\nرقم المرجع: ${result.referenceNumber}' : ''}'
              : result.message,
          onDismiss: () => ctrl.resetResult(),
        );
      }
      return const SizedBox.shrink();
    });
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String text;
  final VoidCallback onDismiss;

  const _Banner({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.text,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600, height: 1.5)),
          ),
          GestureDetector(onTap: onDismiss, child: Icon(Icons.close, size: 18, color: color.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}
