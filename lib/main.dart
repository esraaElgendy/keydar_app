import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/app_controller.dart';
import 'controllers/auth_controller.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'screens/auth/account_type_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/property_details/property_details_screen.dart';
import 'screens/car_details/car_details_screen.dart';
import 'screens/filter/filter_screen.dart';
import 'screens/booking/booking_confirmation_screen.dart';
import 'screens/my_bookings/bookings_router.dart';
import 'screens/profile/profile_router.dart';
import 'screens/account/tenants_list_screen.dart';
import 'screens/account/tenant_detail_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/notifications_screen.dart';
import 'screens/profile/contact_us_screen.dart';
import 'screens/owner_dashboard/owner_dashboard_screen.dart';
import 'screens/owner_dashboard/all_orders_screen.dart';
import 'screens/booking_requests/booking_requests_screen.dart';
import 'screens/my_properties/my_properties_screen.dart';
import 'screens/add_property/add_property_screen.dart';
import 'screens/booking_detail/booking_detail_screen.dart';
import 'screens/host_profile/host_profile_overlay.dart';

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
      initialBinding: BindingsBuilder(() {
        Get.put(AppController());
        Get.put(AuthController());
      }),
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
        GetPage(name: AppRoutes.myBookings, page: () => const BookingsRouter()),
        GetPage(name: AppRoutes.profile, page: () => const ProfileRouter()),
        GetPage(name: AppRoutes.tenantsList, page: () => const TenantsListScreen()),
        GetPage(name: AppRoutes.tenantDetail, page: () => const TenantDetailScreen()),
        GetPage(name: AppRoutes.editProfile, page: () => const EditProfileScreen()),
        GetPage(name: AppRoutes.notifications, page: () => const NotificationsScreen()),
        GetPage(name: AppRoutes.contactUs, page: () => const ContactUsScreen()),
        GetPage(name: AppRoutes.accountType, page: () => const AccountTypeScreen()),
        GetPage(name: AppRoutes.ownerDashboard, page: () => const OwnerDashboardScreen()),
        GetPage(name: AppRoutes.myProperties, page: () => const MyPropertiesScreen()),
        GetPage(name: AppRoutes.addProperty, page: () => const AddPropertyScreen()),
        GetPage(name: AppRoutes.bookingDetail, page: () => const BookingDetailScreen()),
        GetPage(name: AppRoutes.allOrders, page: () => const AllOrdersScreen()),
        GetPage(name: AppRoutes.bookingRequests, page: () => const BookingRequestsScreen()),
        GetPage(name: AppRoutes.hostProfile, page: () => const HostProfileOverlay()),
      ],
      initialRoute: AppRoutes.splash,
    );
  }
}
