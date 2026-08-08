import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _acceptTerms = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthController get _auth => AuthController.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_acceptTerms) {
      Get.snackbar('تنبيه', 'يجب الموافقة على شروط الخدمة وسياسة الخصوصية أولاً');
      return;
    }
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى ملء جميع الحقول');
      return;
    }

    final success = await _auth.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!success) {
      Get.snackbar(
        'تعذر إنشاء الحساب',
        _auth.errorMessage.value ?? 'حدث خطأ ما، حاول مرة أخرى',
      );
      return;
    }

    // التسجيل يعيد توكن مباشرة — ننتقل لشاشة التحقق ثم للرئيسية.
    Get.offNamed(AppRoutes.verification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_forward, color: AppColors.black, size: 24),
                  ),
                ],
              ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Text(
                      AppStrings.signUpTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      AppStrings.signUpSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: AppStrings.fullName,
                      icon: Icons.person_outline,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: AppStrings.email,
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: AppStrings.phoneNumber,
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: AppStrings.password,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.right,
                            text: const TextSpan(
                              style: TextStyle(fontSize: 12, color: AppColors.grey, height: 1.5),
                              children: [
                                TextSpan(text: 'بإنشائك للحساب، أنت توافق على '),
                                TextSpan(
                                  text: 'شروط الخدمة',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: ' و '),
                                TextSpan(
                                  text: 'سياسة الخصوصية.',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _acceptTerms,
                            onChanged: (v) => setState(() => _acceptTerms = v!),
                            activeColor: AppColors.primary,
                            checkColor: AppColors.white,
                            side: const BorderSide(color: AppColors.fieldBorder, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _auth.isLoading.value ? null : _onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: Obx(
                          () => _auth.isLoading.value
                              ? const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  AppStrings.createAccountBtn,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
