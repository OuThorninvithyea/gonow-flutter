import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gonow/models/booking.dart';
import 'package:gonow/models/rental_plan.dart';
import 'package:gonow/models/vehicle_listing.dart';
import 'package:gonow/screens/booking/booking_summary_screen.dart';

Booking _booking() {
  final start = DateTime(2026, 1, 1, 14, 30);
  return Booking(
    vehicle: vehicleListings.first,
    plan: RentalPlan.daily,
    start: start,
    end: start.add(RentalPlan.daily.duration),
    bookingId: 'GN-BK-1024',
  );
}

Widget _wrap(Booking booking) {
  final router = GoRouter(
    initialLocation: '/summary',
    routes: [
      GoRoute(
        path: '/summary',
        builder: (context, state) => BookingSummaryScreen(booking: booking),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) =>
            const Scaffold(body: Text('payment screen')),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

/// The terms checkbox and CTA sit at the bottom of a scrollable card stack,
/// so on the default (small) test viewport they can start below the fold.
Future<void> _acceptTerms(WidgetTester tester) async {
  final termsFinder = find.text('I agree to the rental and safety terms.');
  await tester.ensureVisible(termsFinder);
  await tester.tap(termsFinder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the vehicle, schedule, and price breakdown', (
    tester,
  ) async {
    final booking = _booking();
    await tester.pumpWidget(_wrap(booking));

    expect(find.text('Booking\nsummary.'), findsOneWidget);
    expect(find.text(booking.vehicle.code), findsOneWidget);
    expect(find.text(booking.vehicle.location), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Rental price'), findsOneWidget);
    expect(find.text(booking.formattedRentalPrice), findsOneWidget);
    expect(find.text(booking.formattedTotal), findsWidgets);
  });

  testWidgets('Continue to Payment is disabled until terms are accepted', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_booking()));

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continue to Payment'),
    );
    expect(button.onPressed, isNull);

    await _acceptTerms(tester);

    final enabledButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continue to Payment'),
    );
    expect(enabledButton.onPressed, isNotNull);
  });

  testWidgets('accepting terms and continuing pushes the payment screen', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_booking()));

    await _acceptTerms(tester);
    await tester.tap(find.text('Continue to Payment'));
    await tester.pumpAndSettle();

    expect(find.text('payment screen'), findsOneWidget);
  });
}
