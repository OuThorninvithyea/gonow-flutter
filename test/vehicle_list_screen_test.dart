import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gonow/providers/saved_vehicles_provider.dart';
import 'package:gonow/screens/home/vehicle_list_screen.dart';

late SavedVehiclesProvider saved;

Widget _wrap() {
  saved = SavedVehiclesProvider();
  final router = GoRouter(
    initialLocation: '/vehicles',
    routes: [
      GoRoute(
        path: '/vehicles',
        builder: (_, _) => const VehicleListScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('home screen')),
      ),
    ],
  );
  return ChangeNotifierProvider.value(
    value: saved,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('renders the header and every category chip', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Choose your ride.'), findsOneWidget);
    for (final chip in ['All', 'e-scooter', 'electric', 'SUV']) {
      expect(find.text(chip), findsOneWidget, reason: 'missing chip: $chip');
    }
  });

  testWidgets('e-scooter is selected by default and shows all four bikes', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Found 4 vehicles'), findsOneWidget);
    expect(find.text('Fortuner GR'), findsOneWidget);
    expect(find.text('Volt Cruiser'), findsOneWidget);
  });

  testWidgets('switching to a category with no matches shows the empty '
      'state', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('SUV'));
    await tester.pumpAndSettle();

    expect(find.text('No vehicles in this category yet.'), findsOneWidget);
  });

  testWidgets('tapping the heart toggles the saved state', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(saved.isSaved('fortuner-gr'), isFalse);

    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();

    expect(saved.isSaved('fortuner-gr'), isTrue);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('tapping the arrow opens the rent sheet', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_forward).first);
    await tester.pumpAndSettle();

    expect(find.text('Rent now'), findsOneWidget);
  });

  testWidgets('the back arrow pops the route', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
  });
}
