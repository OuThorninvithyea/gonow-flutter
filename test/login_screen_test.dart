import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gonow/providers/auth_provider.dart';
import 'package:gonow/screens/auth/login_screen.dart';

/// A real router, so `context.push('/forgot-password')` is exercised rather
/// than throwing "No GoRouter found in context".
Widget _wrap() {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const Scaffold(body: Text('forgot password screen')),
      ),
    ],
  );
  return ChangeNotifierProvider(
    create: (_) => AuthProvider(),
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('renders the sign-in form without overflowing', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Lets Sign you in'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    // The headline must stay on one line. Two lines at 37pt would be ~87pt.
    expect(tester.getSize(find.text('Lets Sign you in')).height, lessThan(60));
    expect(find.text('Forgot Password ?'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('blocks submission until both fields are valid', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email, phone or username'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);

    // A too-short password must keep the form invalid.
    await tester.enterText(find.byType(TextFormField).first, 'rider@gonow.app');
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('routes to the forgot-password flow', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Forgot Password ?'));
    await tester.tap(find.text('Forgot Password ?'));
    await tester.pumpAndSettle();

    expect(find.text('forgot password screen'), findsOneWidget);
  });
}
