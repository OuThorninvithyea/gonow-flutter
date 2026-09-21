import 'package:go_router/go_router.dart';
import 'tab_navigation.dart';
import '../../models/booking.dart';
import '../../models/vehicle_listing.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/booking/booking_confirmed_screen.dart';
import '../../screens/booking/booking_receipt_screen.dart';
import '../../screens/booking/booking_summary_screen.dart';
import '../../screens/booking/payment_screen.dart';
import '../../screens/booking/rental_plan_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/reset_new_password_screen.dart';
import '../../screens/auth/reset_password_code_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/map_screen.dart';
import '../../screens/home/notification_screen.dart';
import '../../screens/home/profile_screen.dart';
import '../../screens/home/rental_history_screen.dart';
import '../../screens/home/saved_screen.dart';
import '../../screens/home/vehicle_list_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/splash/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => slidePage(state, const LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => slidePage(state, const RegisterScreen()),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) => const OtpVerificationScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password/code',
      builder: (context, state) => const ResetPasswordCodeScreen(),
    ),
    GoRoute(
      path: '/reset-password/new',
      builder: (context, state) => const ResetNewPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => slidePage(state, const HomeScreen()),
    ),
    GoRoute(
      path: '/map',
      pageBuilder: (context, state) => slidePage(
        state,
        MapScreen(
          vehicle: state.extra is VehicleListing
              ? state.extra! as VehicleListing
              : null,
        ),
      ),
    ),
    GoRoute(
      path: '/vehicles',
      builder: (context, state) => const VehicleListScreen(),
    ),
    GoRoute(
      path: '/rentals',
      pageBuilder: (context, state) =>
          slidePage(state, const RentalHistoryScreen()),
    ),
    GoRoute(
      path: '/saved',
      pageBuilder: (context, state) => slidePage(state, const SavedScreen()),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => slidePage(state, const ProfileScreen()),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: '/rental-plan',
      builder: (context, state) =>
          RentalPlanScreen(vehicle: state.extra! as VehicleListing),
    ),
    GoRoute(
      path: '/booking-summary',
      builder: (context, state) =>
          BookingSummaryScreen(booking: state.extra! as Booking),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) =>
          PaymentScreen(booking: state.extra! as Booking),
    ),
    GoRoute(
      path: '/booking-confirmed',
      builder: (context, state) =>
          BookingConfirmedScreen(booking: state.extra! as Booking),
    ),
    GoRoute(
      path: '/booking-receipt',
      builder: (context, state) =>
          BookingReceiptScreen(booking: state.extra! as Booking),
    ),
  ],
);
