import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gonow/screens/home/rental_history_screen.dart';

Widget _wrap() {
  final router = GoRouter(
    initialLocation: '/rentals',
    routes: [
      GoRoute(path: '/rentals', builder: (_, _) => const RentalHistoryScreen()),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('home screen')),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  testWidgets('pins the only rental history header while records scroll', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Rental history'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rental history'), findsOneWidget);
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

  testWidgets(
    'defaults to the most recent month and totals its rides correctly',
    (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Rental history'), findsOneWidget);
      expect(find.text('SEPTEMBER 2026'), findsOneWidget);
      expect(find.text('4 rides'), findsOneWidget);
      expect(find.text('\$13.20'), findsOneWidget);
      expect(find.text('September ⌄'), findsOneWidget);
    },
  );

  testWidgets('lists every ride in the selected month, most recent first', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('BKK1 → Wat Phnom'), findsOneWidget);
    expect(find.text('Riverside → BKK1'), findsOneWidget);
    expect(find.text('Olympic Market → Toul Kork'), findsOneWidget);
    expect(find.text('Wat Phnom → Riverside'), findsOneWidget);
    // August rides must not leak into the September list.
    expect(find.text('Toul Kork → BKK1'), findsNothing);

    final rows = tester.getTopLeft(find.text('BKK1 → Wat Phnom'));
    final laterRow = tester.getTopLeft(find.text('Wat Phnom → Riverside'));
    expect(rows.dy, lessThan(laterRow.dy));
  });

  testWidgets('switching the month via the picker updates the list and '
      'summary', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('September ⌄'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('August 2026'));
    await tester.pumpAndSettle();

    expect(find.text('AUGUST 2026'), findsOneWidget);
    expect(find.text('2 rides'), findsOneWidget);
    expect(find.text('\$5.70'), findsOneWidget);
    expect(find.text('Toul Kork → BKK1'), findsOneWidget);
    expect(find.text('BKK1 → Olympic Market'), findsOneWidget);
    expect(find.text('BKK1 → Wat Phnom'), findsNothing);
  });

  testWidgets('tapping a ride opens its receipt', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('BKK1 → Wat Phnom'));
    await tester.pumpAndSettle();

    expect(find.text('Amount paid'), findsOneWidget);
    expect(find.text('\$3.10'), findsWidgets);
    expect(find.text('KHQR'), findsOneWidget);
  });

  testWidgets('the back control returns to home', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
  });
}
