import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:gonow/providers/auth_provider.dart';
import 'package:gonow/screens/auth/login_screen.dart';

Widget _wrap() => ChangeNotifierProvider(
  create: (_) => AuthProvider(),
  child: const MaterialApp(home: LoginScreen()),
);

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

  testWidgets('surfaces unimplemented providers instead of failing silently', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Forgot Password ?'));
    await tester.tap(find.text('Forgot Password ?'));
    await tester.pump();

    expect(find.textContaining('not wired up yet'), findsOneWidget);
  });
}
