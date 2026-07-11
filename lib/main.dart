import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/property_details/property_details_screen.dart';
import 'screens/car_details/car_details_screen.dart';
import 'screens/filter/filter_screen.dart';
import 'screens/booking/booking_confirmation_screen.dart';
import 'screens/my_bookings/my_bookings_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/notifications_screen.dart';
import 'screens/profile/contact_us_screen.dart';

void main() {
  runApp(const KeyDarApp());
}

class KeyDarApp extends StatelessWidget {
  const KeyDarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KeyDar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      textDirection: TextDirection.rtl,
      locale: const Locale('ar', 'AE'),
      fallbackLocale: const Locale('ar', 'AE'),
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
        GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
        GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
        GetPage(name: AppRoutes.signUp, page: () => const SignUpScreen()),
        GetPage(name: AppRoutes.verification, page: () => const VerificationScreen()),
        GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
        GetPage(name: AppRoutes.explore, page: () => const ExploreScreen()),
        GetPage(name: AppRoutes.favorites, page: () => const FavoritesScreen()),
        GetPage(name: AppRoutes.propertyDetails, page: () => const PropertyDetailsScreen()),
        GetPage(name: AppRoutes.carDetails, page: () => const CarDetailsScreen()),
        GetPage(name: AppRoutes.filter, page: () => const FilterScreen()),
        GetPage(name: AppRoutes.bookingConfirmation, page: () => const BookingConfirmationScreen()),
        GetPage(name: AppRoutes.myBookings, page: () => const MyBookingsScreen()),
        GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
        GetPage(name: AppRoutes.editProfile, page: () => const EditProfileScreen()),
        GetPage(name: AppRoutes.notifications, page: () => const NotificationsScreen()),
        GetPage(name: AppRoutes.contactUs, page: () => const ContactUsScreen()),
      ],
      initialRoute: AppRoutes.splash,
    );
  }
}
