import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                    const CustomTextField(
                      label: AppStrings.fullName,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    const CustomTextField(
                      label: AppStrings.email,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    const CustomTextField(
                      label: AppStrings.phoneNumber,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    const CustomTextField(
                      label: AppStrings.password,
                      icon: Icons.lock_outline,
                      isPassword: true,
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
                        onPressed: () => Get.toNamed(AppRoutes.verification),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: const Text(
                          AppStrings.createAccountBtn,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
