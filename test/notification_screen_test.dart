import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gonow/screens/home/notification_screen.dart';
import 'package:gonow/widgets/app_bottom_nav.dart';

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
  testWidgets('pins the only notification header while the feed scrolls', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Notification'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Notification'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Back',
      ),
      findsOneWidget,
    );
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

  testWidgets('renders the header and every notification from the feed', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Notification'), findsOneWidget);
    expect(find.text('Stay up to date with your rides.'), findsOneWidget);
    expect(find.text('6 new'), findsOneWidget);

    for (final title in ['Ride Confirmed', 'Charge alert']) {
      expect(find.text(title), findsOneWidget, reason: 'missing: $title');
    }

    for (final filter in ['All', 'Unread', 'Rides']) {
      expect(find.text(filter), findsOneWidget, reason: 'missing: $filter');
    }

    // Later feed items only exist once the list scrolls to reach them —
    // the bottom nav bar takes up viewport space the Figma frame didn't
    // account for, so even "New station nearby" (item 3) needs a scroll now.
    for (final title in [
      'New station nearby',
      'Promo unlocked',
      'Maintenance notice',
      'Ride completed',
    ]) {
      await tester.dragUntilVisible(
        find.text(title),
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget, reason: 'missing: $title');
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

  testWidgets('has a bottom nav bar and the Home tab also returns home', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNav), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Home',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
  });
}
