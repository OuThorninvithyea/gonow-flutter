import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gonow/models/vehicle_listing.dart';
import 'package:gonow/screens/booking/rental_plan_screen.dart';

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
}
