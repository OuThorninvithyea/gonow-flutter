import 'package:go_router/go_router.dart';
import '../../models/vehicle_listing.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/booking/rental_plan_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/reset_new_password_screen.dart';
import '../../screens/auth/reset_password_code_screen.dart';
import '../../screens/home/home_screen.dart';
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
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
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
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/vehicles',
      builder: (context, state) => const VehicleListScreen(),
    ),
    GoRoute(
      path: '/rental-plan',
      builder: (context, state) =>
          RentalPlanScreen(vehicle: state.extra! as VehicleListing),
    ),
  ],
);
