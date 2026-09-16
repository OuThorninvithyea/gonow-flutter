import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gonow/providers/auth_provider.dart';
import 'package:gonow/providers/saved_vehicles_provider.dart';
import 'package:gonow/screens/home/home_screen.dart';
import 'package:gonow/screens/home/vehicle_list_screen.dart';
import 'package:gonow/widgets/app_bottom_nav.dart';

late AuthProvider auth;

Widget _wrap() {
  auth = AuthProvider();
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/vehicles',
        builder: (_, _) => const VehicleListScreen(),
      ),
    ],
  );
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider(create: (_) => SavedVehiclesProvider()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('renders every section of the design', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Standard member'), findsOneWidget);
    expect(find.text('Promotions Today 20%'), findsOneWidget);
    expect(find.text('Book your Scooter now!!'), findsOneWidget);
    for (final chip in ['Nearby', 'Battery 80%+', 'Daily', 'Weekly']) {
      expect(find.text(chip), findsOneWidget, reason: 'missing chip: $chip');
    }
    expect(find.text('e-sctooer'), findsOneWidget);
    expect(find.text('Fortuner GR'), findsOneWidget);
    expect(find.text(r'$ 7.5/day'), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
  });

  testWidgets('falls back to a rider name when signed out', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    // No user on the provider, so the header must not render null or crash.
    expect(find.text('Rider'), findsOneWidget);
    expect(find.text('R'), findsOneWidget, reason: 'avatar initial');
  });

  testWidgets('selecting a filter chip moves the highlight and swaps the '
      'featured vehicle', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    Color chipColor(String label) {
      final container = tester.widget<Container>(
        find
            .ancestor(of: find.text(label), matching: find.byType(Container))
            .first,
      );
      return (container.decoration as BoxDecoration).color!;
    }

    final limeWhenDefault = chipColor('Nearby');
    expect(find.text('Fortuner GR'), findsOneWidget);

    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();

    expect(chipColor('Daily'), limeWhenDefault);
    expect(chipColor('Nearby'), isNot(limeWhenDefault));
    expect(find.text('City Hopper'), findsOneWidget);
    expect(find.text('Fortuner GR'), findsNothing);
  });

  testWidgets('tapping the vehicle card opens the rent sheet', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final cardFinder = find.text('Fortuner GR');
    await tester.ensureVisible(cardFinder);
    await tester.pumpAndSettle();
    await tester.tap(cardFinder);
    await tester.pumpAndSettle();

    expect(find.text('Rent now'), findsOneWidget);
  });

  testWidgets('the rent sheet offers a color picker with an unavailable '
      'color disabled', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final cardFinder = find.text('Fortuner GR');
    await tester.ensureVisible(cardFinder);
    await tester.pumpAndSettle();
    await tester.tap(cardFinder);
    await tester.pumpAndSettle();

    expect(find.text('Silver'), findsOneWidget);
    expect(find.text('Sold out'), findsNothing);

    final redSwatch = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'Red, sold out',
    );
    expect(redSwatch, findsOneWidget);
    await tester.tap(redSwatch, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Disabled swatch: selection must not change.
    expect(find.text('Silver'), findsOneWidget);
    expect(find.text('Sold out'), findsNothing);

    final blackSwatch = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'Black',
    );
    await tester.tap(blackSwatch);
    await tester.pumpAndSettle();

    expect(find.text('Black'), findsOneWidget);
  });

  testWidgets('the bell icon opens notifications', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home_bell_button')));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('View more navigates to the full vehicle list', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('View more'));
    await tester.pumpAndSettle();

    expect(find.byType(VehicleListScreen), findsOneWidget);
    expect(find.text('Choose your ride.'), findsOneWidget);
  });

  testWidgets('unbuilt nav tabs say so rather than doing nothing', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rentals'));
    await tester.pump();

    expect(find.textContaining('coming soon'), findsOneWidget);
  });
}
