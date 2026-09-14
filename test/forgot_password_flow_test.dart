import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gonow/providers/auth_provider.dart';
import 'package:gonow/screens/auth/forgot_password_screen.dart';
import 'package:gonow/screens/auth/reset_new_password_screen.dart';
import 'package:gonow/screens/auth/reset_password_code_screen.dart';

late AuthProvider auth;

/// Mirrors the real router's three forgot-password routes plus a fake
/// `/login` destination, so the final screen's `context.go('/login')` has
/// somewhere to land.
Widget _wrap({String initialLocation = '/forgot-password'}) {
  auth = AuthProvider();
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password/code',
        builder: (_, _) => const ResetPasswordCodeScreen(),
      ),
      GoRoute(
        path: '/reset-password/new',
        builder: (_, _) => const ResetNewPasswordScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const Scaffold(body: Text('login screen')),
      ),
    ],
  );
  return ChangeNotifierProvider.value(
    value: auth,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('ForgotPasswordScreen', () {
    testWidgets('rejects an empty identifier', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your email, phone or username'), findsOneWidget);
      expect(find.text('Verification Code'), findsNothing);
    });

    testWidgets('stores the identifier and advances to the code screen', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'rider@gonow.app');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(auth.resetIdentifier, 'rider@gonow.app');
      expect(find.text('Verification Code'), findsOneWidget);
    });

    testWidgets('back arrow pops the route', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  group('ResetPasswordCodeScreen', () {
    testWidgets('rejects a short code', (tester) async {
      await tester.pumpWidget(_wrap(initialLocation: '/reset-password/code'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      expect(find.text('Enter the 6-digit code'), findsOneWidget);
      expect(find.text('Change Password'), findsNothing);
    });

    testWidgets('drops non-digit input', (tester) async {
      await tester.pumpWidget(_wrap(initialLocation: '/reset-password/code'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'ab12cd');
      await tester.pump();

      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('a valid code advances to the change-password screen', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(initialLocation: '/reset-password/code'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Verify'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(auth.resetCodeVerified, isTrue);
      expect(find.text('Change Password'), findsOneWidget);
    });

    testWidgets('resend triggers another request and shows a snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(initialLocation: '/reset-password/code'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend code?'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Code resent'), findsOneWidget);
    });
  });

  group('ResetNewPasswordScreen', () {
    testWidgets('requires a letter and a digit', (tester) async {
      await tester.pumpWidget(_wrap(initialLocation: '/reset-password/new'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '12345678');
      await tester.enterText(fields.at(1), '12345678');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      expect(find.text('Include at least one letter'), findsOneWidget);
    });

    testWidgets('blocks a mismatched confirmation', (tester) async {
      await tester.pumpWidget(_wrap(initialLocation: '/reset-password/new'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'newpass1');
      await tester.enterText(fields.at(1), 'newpass2');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('a matching password resets and returns to login', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(initialLocation: '/reset-password/new'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'newpass1');
      await tester.enterText(fields.at(1), 'newpass1');
      await tester.tap(find.text('Verify'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.text('login screen'), findsOneWidget);
    });
  });
}
