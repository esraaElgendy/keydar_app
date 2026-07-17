import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      image: AppAssets.onboarding1,
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
    ),
    _OnboardingData(
      image: AppAssets.onboarding2,
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
    ),
    _OnboardingData(
      image: AppAssets.onboarding3,
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
    ),
  ];

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _goToNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offNamed(AppRoutes.accountType);
    }
  }

  void _skip() {
    Get.offNamed(AppRoutes.accountType);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _pages.map((p) {
              return OnboardingPage(
                imagePath: p.image,
                title: p.title,
                subtitle: p.subtitle,
              );
            }).toList(),
          ),
          Positioned(
            top: 60,
            right: 20,
            child: GestureDetector(
              onTap: _skip,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  AppStrings.skip,
                  style: TextStyle(color: AppColors.white, fontSize: 14),
                ),
              ),
            ),
          ),
          if (_currentPage > 0)
            Positioned(
              top: 60,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: AppColors.white, size: 20),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 120,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == _currentPage ? 32 : 16,
                      height: 4,
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? AppColors.white
                            : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 50,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _goToNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentPage < _pages.length - 1) ...[
                      const Icon(Icons.arrow_back, color: AppColors.black, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _currentPage == _pages.length - 1
                          ? AppStrings.startNow
                          : AppStrings.next,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String image;
  final String title;
  final String subtitle;

  const _OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
