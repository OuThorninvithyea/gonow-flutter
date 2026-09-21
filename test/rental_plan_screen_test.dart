import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gonow/models/vehicle_listing.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gonow/providers/saved_vehicles_provider.dart';
import 'package:gonow/screens/booking/rental_plan_screen.dart';
import 'package:gonow/widgets/vehicle_detail_sheet.dart';

void main() {
  testWidgets('plan selection updates return-by line', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: RentalPlanScreen(vehicle: vehicleListings.first)),
    );

    expect(find.text('Choose your\nrental plan.'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.textContaining('Tomorrow'), findsOneWidget);

    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tomorrow'), findsNothing);
    expect(find.text('Continue to booking'), findsOneWidget);
  });

  testWidgets('Rent now in the detail sheet lands on the plan screen', (
    tester,
  ) async {
    final vehicle = vehicleListings.first;
    final router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(
          path: '/start',
          builder: (context, _) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showVehicleDetailSheet(context, vehicle),
                child: const Text('open sheet'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/rental-plan',
          builder: (context, state) =>
              RentalPlanScreen(vehicle: state.extra! as VehicleListing),
        ),
      ],
    );
    // The rent sheet's heart reads SavedVehiclesProvider.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SavedVehiclesProvider(),
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.text('open sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Rent now'), findsOneWidget);

    await tester.tap(find.text('Rent now'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your\nrental plan.'), findsOneWidget);
  });
}
