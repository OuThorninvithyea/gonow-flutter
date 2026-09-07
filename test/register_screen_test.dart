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

void main() {
  testWidgets('renders all five fields from the design', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Lets Register\nAccount'), findsOneWidget);
    for (final hint in [
      'Name',
      'Buissness name',
      'Phone',
      'Email',
      'Password',
    ]) {
      expect(find.text(hint), findsOneWidget, reason: 'missing field: $hint');
    }
    expect(find.text('Register Now'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('rejects a malformed email', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sok Dara');
    await tester.enterText(fields.at(2), '012345678');
    await tester.enterText(fields.at(3), 'not-an-email');
    await tester.enterText(fields.at(4), 'secret123');

    await tester.ensureVisible(find.text('Register Now'));
    await tester.tap(find.text('Register Now'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(auth.user, isNull, reason: 'must not register on invalid input');
  });

  testWidgets('registers and carries email plus optional business name', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sok Dara');
    await tester.enterText(fields.at(1), 'Dara Rentals');
    await tester.enterText(fields.at(2), '012345678');
    await tester.enterText(fields.at(3), 'dara@gonow.app');
    await tester.enterText(fields.at(4), 'secret123');

    await tester.ensureVisible(find.text('Register Now'));
    await tester.tap(find.text('Register Now'));
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

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sok Dara');
    await tester.enterText(fields.at(2), '012345678');
    await tester.enterText(fields.at(3), 'dara@gonow.app');
    await tester.enterText(fields.at(4), 'secret123');

    await tester.ensureVisible(find.text('Register Now'));
    await tester.tap(find.text('Register Now'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(auth.user?.businessName, isNull);
  });
}
