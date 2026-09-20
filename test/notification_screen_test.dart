import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gonow/screens/home/notification_screen.dart';

Widget _wrap() {
  final router = GoRouter(
    initialLocation: '/notifications',
    routes: [
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('home screen')),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
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

  testWidgets('renders the header and every notification from the feed', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Notification'), findsWidgets);
    expect(find.text('Stay up to date with your rides.'), findsOneWidget);
    expect(find.text('6 new'), findsOneWidget);

    for (final title in [
      'Ride Confirmed',
      'Charge alert',
      'New station nearby',
      'Promo unlocked',
    ]) {
      expect(find.text(title), findsOneWidget, reason: 'missing: $title');
    }

    // The list is a ListView, so later items only exist once scrolled into
    // view.
    await tester.dragUntilVisible(
      find.text('Ride completed'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    for (final title in ['Maintenance notice', 'Ride completed']) {
      expect(find.text(title), findsOneWidget, reason: 'missing: $title');
    }

    for (final filter in ['All', 'Unread', 'Rides']) {
      expect(find.text(filter), findsOneWidget, reason: 'missing: $filter');
    }
  });

  testWidgets('tapping Unread or Rides says filtering is coming soon', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Unread'));
    await tester.pump();

    expect(find.textContaining('coming soon'), findsOneWidget);
    // The feed itself doesn't actually filter yet.
    await tester.dragUntilVisible(
      find.text('Ride completed'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('Ride completed'), findsOneWidget);
  });

  testWidgets('the back control returns to home', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('←'));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
  });
}
