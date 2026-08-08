import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';

/// تعديل المعلومات الشخصية: يدخل في وضع التعديل ويعرض "حفظ التعديلات",
/// وعند الحفظ يرسل الـ PUT إلى `/customers/profile` ويحدّث البيانات.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _syncFromCustomer();
  }

  void _syncFromCustomer() {
    final c = AuthController.instance.customer.value;
    _firstName.text = c?.firstName ?? '';
    _lastName.text = c?.lastName ?? '';
    _email.text = c?.email ?? '';
    _phone.text = c?.phone ?? '';
    _city.text = c?.city ?? '';
    _address.text = c?.address ?? '';
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _city.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    final first = _firstName.text.trim();
    final last = _lastName.text.trim();
    final phone = _phone.text.trim();
    if (first.isEmpty || last.isEmpty || phone.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى ملء الاسم والجوال');
      return;
    }
    setState(() => _isSaving = true);
    final ok = await AuthController.instance.updateProfile(
      firstName: first,
      lastName: last,
      phone: phone,
      city: _city.text.trim().isEmpty ? null : _city.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      _syncFromCustomer();
      setState(() => _isEditing = false);
      Get.snackbar('تم الحفظ', 'تم تحديث البيانات بنجاح');
    } else {
      Get.snackbar('خطأ', AuthController.instance.errorMessage.value ?? 'حدث خطأ، حاول مرة أخرى');
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _isEditing;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Stack(
                children: [
                  Center(
                    child: Text('المعلومات الشخصية',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black)),
                  ),
                  Positioned(
                    left: 0,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.arrow_forward, color: AppColors.black, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Stack(
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.fieldBorder),
                          child: const Icon(Icons.person, size: 50, color: AppColors.grey),
                        ),
                        Positioned(bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: enabled ? () => _pickAvatar() : null,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                              child: const Icon(Icons.edit, size: 16, color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('تغيير الصورة الشخصية',
                      style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),
                    _Form(
                      enabled: enabled,
                      firstName: _firstName,
                      lastName: _lastName,
                      email: _email,
                      phone: _phone,
                      city: _city,
                      address: _address,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : (enabled ? _handleSave : () => setState(() => _isEditing = true)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 6,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: Text(
                          _isSaving
                              ? 'جارٍ الحفظ...'
                              : (enabled ? 'حفظ التعديلات' : 'تعديل'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickAvatar() {
    // TODO: اختيار صورة شخصية — خارج نطاق التعديل الحالي.
  }
}

class _Form extends StatelessWidget {
  final bool enabled;
  final TextEditingController firstName, lastName, email, phone, city, address;
  const _Form({required this.enabled, required this.firstName, required this.lastName, required this.email, required this.phone, required this.city, required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Field(label: 'الاسم الأول', icon: Icons.person_outline, controller: firstName, enabled: enabled),
        const SizedBox(height: 16),
        _Field(label: 'اسم العائلة', icon: Icons.person_outline, controller: lastName, enabled: enabled),
        const SizedBox(height: 16),
        _Field(label: 'البريد الإلكتروني', icon: Icons.email_outlined, controller: email, enabled: false),
        const SizedBox(height: 16),
        _Field(label: 'رقم الجوال', icon: Icons.phone_outlined, controller: phone, enabled: enabled),
        const SizedBox(height: 16),
        _Field(label: 'المدينة', icon: Icons.location_city_outlined, controller: city, enabled: enabled),
        const SizedBox(height: 16),
        _Field(label: 'العنوان', icon: Icons.home_outlined, controller: address, enabled: enabled),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool enabled;
  const _Field({required this.label, required this.icon, required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
        ),
        TextField(
          controller: controller,
          enabled: enabled,
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 14, color: enabled ? AppColors.black : AppColors.darkText),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled ? AppColors.white : const Color(0xFFF1F5F9),
            prefixIcon: Icon(icon, size: 20, color: AppColors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: enabled ? AppColors.fieldBorder : Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.fieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}