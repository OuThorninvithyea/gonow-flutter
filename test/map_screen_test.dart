import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gonow/models/vehicle_listing.dart';
import 'package:gonow/screens/home/map_screen.dart';

Widget _wrap({VehicleListing? vehicle}) {
  final router = GoRouter(
    initialLocation: '/map',
    routes: [
      GoRoute(
        path: '/map',
        builder: (_, _) => MapScreen(vehicle: vehicle),
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
  testWidgets('renders the static map, header, and default nearby vehicle', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsWidgets);
    expect(find.text('Phnom Penh'), findsOneWidget);
    expect(find.text('Search pickup location'), findsOneWidget);
    expect(find.text('NEARBY SCOOTER'), findsOneWidget);

    // "Nearby" filter is selected by default, matching Fortuner GR.
    final nearby = vehicleListings.firstWhere((v) => v.filterTag == 'Nearby');
    expect(find.text(nearby.code), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('From ${nearby.price}'), findsOneWidget);
  });

  testWidgets('selecting a filter swaps the nearby vehicle card', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final daily = vehicleListings.firstWhere((v) => v.filterTag == 'Daily');
    expect(find.text('From ${daily.price}'), findsNothing);

    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();

    expect(find.text('From ${daily.price}'), findsOneWidget);
  });

  testWidgets('View Scooter opens the rent sheet for the shown vehicle', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Scooter'));
    await tester.pumpAndSettle();

    expect(find.text('Rent now'), findsOneWidget);
  });

  testWidgets('the back control returns to home', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('←'));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('a vehicle argument pre-selects its filter and card', (
    tester,
  ) async {
    final weekender = vehicleListings.firstWhere(
      (v) => v.filterTag == 'Weekly',
    );
    await tester.pumpWidget(_wrap(vehicle: weekender));
    await tester.pumpAndSettle();

    // Deep-linked in on "Weekender X" (tagged Weekly) rather than the
    // default "Nearby" pick.
    expect(find.text('From ${weekender.price}'), findsOneWidget);
  });
}
