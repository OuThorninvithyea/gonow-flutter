import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gonow/providers/saved_vehicles_provider.dart';
import 'package:gonow/screens/home/saved_screen.dart';
import 'package:gonow/screens/home/vehicle_list_screen.dart';

late SavedVehiclesProvider saved;

Widget _wrap() {
  saved = SavedVehiclesProvider();
  final router = GoRouter(
    initialLocation: '/saved',
    routes: [
      GoRoute(path: '/saved', builder: (_, _) => const SavedScreen()),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('home screen')),
      ),
      GoRoute(path: '/vehicles', builder: (_, _) => const VehicleListScreen()),
    ],
  );
  return ChangeNotifierProvider.value(
    value: saved,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('shows the empty state when nothing is saved', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Saved scooters'), findsOneWidget);
    expect(find.text('0 saved'), findsOneWidget);
    expect(find.text('No saved scooters yet'), findsOneWidget);
  });

  testWidgets('browsing scooters from the empty state opens the vehicle list', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Browse scooters'));
    await tester.pumpAndSettle();

    expect(find.byType(VehicleListScreen), findsOneWidget);
  });

  testWidgets('lists every saved vehicle with its code and count', (
    tester,
  ) async {
    saved = SavedVehiclesProvider()
      ..toggle('fortuner-gr')
      ..toggle('volt-cruiser');
    final router = GoRouter(
      initialLocation: '/saved',
      routes: [GoRoute(path: '/saved', builder: (_, _) => const SavedScreen())],
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: saved,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 saved'), findsOneWidget);
    expect(find.text('2 scooters'), findsOneWidget);
    expect(find.text('GN-024'), findsNWidgets(2));
    expect(find.byIcon(Icons.favorite), findsNWidgets(2));
    expect(find.text('No saved scooters yet'), findsNothing);
  });

  testWidgets('tapping the heart unsaves the vehicle and updates the list', (
    tester,
  ) async {
    saved = SavedVehiclesProvider()..toggle('fortuner-gr');
    final router = GoRouter(
      initialLocation: '/saved',
      routes: [GoRoute(path: '/saved', builder: (_, _) => const SavedScreen())],
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: saved,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(saved.isSaved('fortuner-gr'), isTrue);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(saved.isSaved('fortuner-gr'), isFalse);
    expect(find.text('No saved scooters yet'), findsOneWidget);
  });

  testWidgets('tapping a saved card opens its detail sheet', (tester) async {
    saved = SavedVehiclesProvider()..toggle('fortuner-gr');
    final router = GoRouter(
      initialLocation: '/saved',
      routes: [GoRoute(path: '/saved', builder: (_, _) => const SavedScreen())],
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: saved,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('GN-024'));
    await tester.pumpAndSettle();

    expect(find.text('Rent now'), findsOneWidget);
  });

  testWidgets('tapping Nearby or Available says filtering is coming soon', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nearby'));
    await tester.pump();

    expect(find.textContaining('coming soon'), findsOneWidget);
  });

  testWidgets('the back control returns to home', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('←'));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
  });

  for (final size in const [Size(360, 640), Size(431, 996), Size(320, 568)]) {
    testWidgets('renders without overflow at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      saved = SavedVehiclesProvider()
        ..toggle('fortuner-gr')
        ..toggle('volt-cruiser')
        ..toggle('city-hopper');
      final router = GoRouter(
        initialLocation: '/saved',
        routes: [
          GoRoute(path: '/saved', builder: (_, _) => const SavedScreen()),
        ],
      );
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: saved,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
