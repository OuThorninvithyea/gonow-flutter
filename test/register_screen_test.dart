import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gonow/providers/auth_provider.dart';
import 'package:gonow/screens/auth/register_screen.dart';

late AuthProvider auth;

/// A real router, so `context.go('/verify-otp')` on success is exercised
/// rather than throwing "No GoRouter found in context".
Widget _wrap() {
  auth = AuthProvider();
  final router = GoRouter(
    initialLocation: '/register',
    routes: [
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/verify-otp',
        builder: (_, _) => const Scaffold(body: Text('otp screen')),
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

// Field order on the form.
const _name = 0;
const _business = 1;
const _phone = 2;
const _email = 3;
const _password = 4;
const _confirm = 5;

/// Fills every field with valid input; pass overrides to break one of them.
Future<void> _fillValid(
  WidgetTester tester, {
  String name = 'Sok Dara',
  String business = '',
  String phone = '012345678',
  String email = 'dara@gonow.app',
  String password = 'secret123',
  String? confirm,
  bool acceptTerms = true,
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(_name), name);
  if (business.isNotEmpty) {
    await tester.enterText(fields.at(_business), business);
  }
  await tester.enterText(fields.at(_phone), phone);
  await tester.enterText(fields.at(_email), email);
  await tester.enterText(fields.at(_password), password);
  await tester.enterText(fields.at(_confirm), confirm ?? password);
  if (acceptTerms) {
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
  }
}

Future<void> _tapRegister(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Register Now'));
  await tester.tap(find.text('Register Now'));
}

void main() {
  testWidgets('renders every field from the design plus the consent gate', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Lets Register\nAccount'), findsOneWidget);
    for (final hint in [
      'Name',
      'Buissness name (optional)',
      'Phone',
      'Email',
      'Password',
      'Confirm password',
    ]) {
      expect(find.text(hint), findsOneWidget, reason: 'missing field: $hint');
    }
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.textContaining('I agree to the'), findsOneWidget);
    expect(find.text('Register Now'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('rejects a malformed email', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await _fillValid(tester, email: 'not-an-email');
    await _tapRegister(tester);
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(auth.user, isNull, reason: 'must not register on invalid input');
  });

  testWidgets('registers and carries email plus optional business name', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await _fillValid(tester, business: 'Dara Rentals');
    await _tapRegister(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(auth.user?.fullName, 'Sok Dara');
    expect(auth.user?.email, 'dara@gonow.app');
    expect(auth.user?.businessName, 'Dara Rentals');
    expect(auth.user?.phoneVerified, isFalse);
    expect(auth.pendingPhone, '012345678');

    await tester.pumpAndSettle();
    expect(find.text('otp screen'), findsOneWidget);
  });

  testWidgets('leaves business name null when blank', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await _fillValid(tester);
    await _tapRegister(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(auth.user?.businessName, isNull);
  });

  testWidgets('rejects a one-character business name', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await _fillValid(tester, business: 'D');
    await _tapRegister(tester);
    await tester.pumpAndSettle();

    expect(find.text('Business name is too short'), findsOneWidget);
    expect(auth.user, isNull);
  });

  group('password', () {
    testWidgets('requires a digit', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await _fillValid(tester, password: 'secretpw');
      await _tapRegister(tester);
      await tester.pumpAndSettle();

      expect(find.text('Include at least one number'), findsOneWidget);
      expect(auth.user, isNull);
    });

    testWidgets('requires a letter', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await _fillValid(tester, password: '12345678');
      await _tapRegister(tester);
      await tester.pumpAndSettle();

      expect(find.text('Include at least one letter'), findsOneWidget);
      expect(auth.user, isNull);
    });

    testWidgets('still enforces the minimum length', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await _fillValid(tester, password: 'a1b');
      await _tapRegister(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
      expect(auth.user, isNull);
    });

    testWidgets('blocks a mismatched confirmation', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await _fillValid(tester, password: 'secret123', confirm: 'secret124');
      await _tapRegister(tester);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(auth.user, isNull);
    });

    testWidgets('blocks an empty confirmation', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await _fillValid(tester, confirm: '');
      await _tapRegister(tester);
      await tester.pumpAndSettle();

      expect(find.text('Re-enter your password'), findsOneWidget);
      expect(auth.user, isNull);
    });
  });

  group('phone', () {
    testWidgets('drops letters instead of accepting them', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await _fillValid(tester, phone: 'abcdefgh');
      await _tapRegister(tester);
      await tester.pumpAndSettle();

      expect(find.text('Enter your phone number'), findsOneWidget);
      expect(auth.user, isNull, reason: 'letters must never pass the field');
    });

    testWidgets('formats as 0XX XXX XXX while typing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(_phone),
        '012345678',
      );
      await tester.pump();

      expect(find.text('012 345 678'), findsOneWidget);
    });

    testWidgets('submits the stripped digits, not the spaced display', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await _fillValid(tester, phone: '0123456789');
      await _tapRegister(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(auth.user?.phone, '0123456789');
      expect(auth.pendingPhone, '0123456789');
    });

    testWidgets('requires a leading zero', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await _fillValid(tester, phone: '123456789');
      await _tapRegister(tester);
      await tester.pumpAndSettle();

      expect(find.text('Phone must start with 0'), findsOneWidget);
      expect(auth.user, isNull);
    });

    testWidgets('rejects a too-short number', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await _fillValid(tester, phone: '01234');
      await _tapRegister(tester);
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid phone number'), findsOneWidget);
      expect(auth.user, isNull);
    });
  });

  group('terms', () {
    testWidgets('blocks registration until accepted', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await _fillValid(tester, acceptTerms: false);
      await _tapRegister(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Accept the Terms and Privacy Policy to continue'),
        findsOneWidget,
      );
      expect(auth.user, isNull);
    });

    testWidgets('clears the error once ticked and lets registration run', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await _fillValid(tester, acceptTerms: false);
      await _tapRegister(tester);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      await _tapRegister(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(auth.user?.fullName, 'Sok Dara');
      await tester.pumpAndSettle();
      expect(find.text('otp screen'), findsOneWidget);
    });
  });
}
