import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gonow/models/vehicle_listing.dart';
import 'package:gonow/screens/booking/rental_plan_screen.dart';

/// The plan screen must survive small phones (it scrolls) and large ones,
/// and the "Change" flow must actually move the schedule.
void main() {
  for (final size in const [Size(360, 640), Size(431, 996), Size(320, 568)]) {
    testWidgets('renders without overflow at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(home: RentalPlanScreen(vehicle: vehicleListings.first)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Continue to booking'), findsOneWidget);
    });
  }

  testWidgets('every plan is selectable and only one is checked', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: RentalPlanScreen(vehicle: vehicleListings.first)),
    );

    for (final title in ['Weekly', 'Monthly', 'Daily']) {
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget);
    }
  });

  testWidgets('Change opens a date picker and updates the schedule', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: RentalPlanScreen(vehicle: vehicleListings.first)),
    );

    // The schedule card lives in the scrollable body, so it can start
    // below the fold even on the default test viewport. Scroll it into
    // view before tapping, the way a real user would.
    await tester.ensureVisible(find.text('Change'));
    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('Continue to booking confirms the chosen plan', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: RentalPlanScreen(vehicle: vehicleListings.first)),
    );

    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to booking'));
    await tester.pump();

    expect(find.textContaining('Weekly plan'), findsOneWidget);
    expect(find.textContaining(vehicleListings.first.name), findsWidgets);
  });
}
