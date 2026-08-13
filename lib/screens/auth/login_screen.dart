import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/account_type.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/account_type.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthController get _auth => AuthController.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    // تحديد نوع الحساب المختار (يصل عبر Get.arguments من شاشة اختيار النوع).
    final type = Get.arguments as String? ?? AccountType.searcher;
    _auth.setAccountType(type);

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى إدخال البريد وكلمة المرور');
      return;
    }

    bool success;
    if (type == AccountType.owner) {
      success = await _auth.ownerLogin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await _auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (!success) {
      Get.snackbar(
        'تعذر تسجيل الدخول',
        _auth.errorMessage.value ?? 'حدث خطأ ما، حاول مرة أخرى',
      );
      return;
    }

    Get.offNamed(type == AccountType.owner ? AppRoutes.ownerDashboard : AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
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
              const SizedBox(height: 4),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/logo/K.png",
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        "KeyDar",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Text(
                      AppStrings.welcomeBack,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      AppStrings.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.greyMedium,
                      ),
                    ),
                    const SizedBox(height: 28),
                    CustomTextField(
                      label: AppStrings.emailOrPhone,
                      icon: Icons.person_outline,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: AppStrings.password,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            AppStrings.forgotPassword,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.primary),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Text(
                              AppStrings.rememberMe,
                              style: TextStyle(fontSize: 14, color: AppColors.darkGrey),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) => setState(() => _rememberMe = v!),
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
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _auth.isLoading.value ? null : _onLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                              : const Text(AppStrings.login),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.fieldBorder)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            AppStrings.orLoginVia,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.fieldBorder)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialButton(
                          icon: Icons.apple,
                          color: AppColors.appleBlack,
                          onTap: () {},
                        ),
                        const SizedBox(width: 20),
                        _SocialButton(
                          icon: Icons.g_mobiledata,
                          color: AppColors.black,
                          onTap: () {},
                          customWidget: Image.asset(AppAssets.google, height: 28),
                        ),
                        const SizedBox(width: 20),
                        _SocialButton(
                          icon: Icons.facebook,
                          color: AppColors.facebookBlue,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppStrings.noAccount,
                          style: TextStyle(fontSize: 14, color: AppColors.grey),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.signUp),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            AppStrings.createAccount,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _SocialButton extends StatelessWidget {
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? customWidget;

  const _SocialButton({
    this.icon,
    required this.color,
    required this.onTap,
    this.customWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: customWidget ??
            Icon(icon, color: color, size: 24),
      ),
    );
  }
}
