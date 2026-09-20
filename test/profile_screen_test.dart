import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gonow/providers/auth_provider.dart';
import 'package:gonow/screens/home/profile_screen.dart';
import 'package:gonow/screens/home/rental_history_screen.dart';

late AuthProvider auth;

Widget _wrap() {
  auth = AuthProvider();
  final router = GoRouter(
    initialLocation: '/profile',
    routes: [
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(
        path: '/rentals',
        builder: (_, _) => const RentalHistoryScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('home screen')),
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
  testWidgets('uses one pinned custom header while content scrolls', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(appBar.pinned, isTrue);
    expect(find.text('Profile'), findsNothing);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Rider'), findsOneWidget);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
  });

  for (final size in const [Size(360, 640), Size(431, 996), Size(320, 568)]) {
    testWidgets('renders without overflow at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('falls back to a rider name and initial when signed out', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Rider'), findsOneWidget);
    expect(find.text('R'), findsOneWidget, reason: 'avatar initial');
  });

  testWidgets("shows the signed-in user's name and initials", (
    tester,
  ) async {
    auth = AuthProvider();
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      ],
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // AuthProvider.register resolves after a simulated network delay
    // (Future.delayed) — inside the test's fake clock that only advances via
    // pump, so don't await the call directly (it would hang forever);
    // instead fire it and pump past the delay.
    unawaited(
      auth.register(
        fullName: 'Sokha Chan',
        phone: '012345678',
        password: 'password',
        email: 'sokha@email.com',
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Sokha Chan'), findsOneWidget);
    expect(find.text('sokha@email.com'), findsOneWidget);
    expect(find.text('SC'), findsOneWidget);
    expect(find.text('Phone verified'), findsOneWidget);
  });

  testWidgets('renders the current plan, payment methods, and saved '
      'locations sections', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Active rental plan'), findsOneWidget);
    expect(find.text('ABA / KHQR'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.text('Home'),
      ),
      findsOneWidget,
    );
    expect(find.text('Work'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('EMERGENCY CONTACT'),
      find.byType(CustomScrollView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(find.text('EMERGENCY CONTACT'), findsOneWidget);
    expect(find.text('+855 12 456 789'), findsOneWidget);
  });

  testWidgets('the notification toggles can be switched', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Promotions'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Promotions'),
      find.byType(CustomScrollView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches.length, 3);
    // Figma: booking confirmations + return reminders start on, promotions
    // starts off.
    expect(switches[0].value, isTrue);
    expect(switches[1].value, isTrue);
    expect(switches[2].value, isFalse);

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();

    final updated = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(updated.last.value, isTrue);
  });

  testWidgets('View all under Rental history opens rental history', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('View all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();

    expect(find.byType(RentalHistoryScreen), findsOneWidget);
  });

  testWidgets('the back control returns to home', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('←'));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('log out signs the user out and returns to login', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Log out'),
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.text('login screen'), findsOneWidget);
    expect(auth.user, isNull);
  });

  testWidgets('secondary actions without a real destination say '
      '"coming soon" rather than doing nothing', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change plan'));
    await tester.pump();

    expect(find.textContaining('coming soon'), findsOneWidget);
  });
}
