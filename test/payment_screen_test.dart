import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gonow/models/booking.dart';
import 'package:gonow/models/rental_plan.dart';
import 'package:gonow/models/vehicle_listing.dart';
import 'package:gonow/screens/booking/payment_screen.dart';

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

void main() {
  testWidgets('shows the processing card, then flips to success', (
    tester,
  ) async {
    final booking = _booking();
    await tester.pumpWidget(
      MaterialApp(
        home: PaymentScreen(
          booking: booking,
          processingDuration: const Duration(milliseconds: 200),
        ),
      ),
    );

    expect(find.text('Processing payment'), findsOneWidget);
    expect(find.text('Payment successful'), findsNothing);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Processing payment'), findsNothing);
    expect(find.text('Payment successful'), findsOneWidget);
    expect(find.text('View Booking'), findsOneWidget);
  });

  testWidgets(
    'the back gesture is blocked while processing but allowed once paid',
    (tester) async {
      final booking = _booking();
      final router = GoRouter(
        initialLocation: '/start',
        routes: [
          GoRoute(
            path: '/start',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      context.push<void>('/payment', extra: booking),
                  child: const Text('open payment'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/payment',
            builder: (context, state) => PaymentScreen(
              booking: state.extra! as Booking,
              processingDuration: const Duration(milliseconds: 500),
            ),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.tap(find.text('open payment'));
      // Let the push transition build (a bare pump), then advance partway
      // through `processingDuration` so the payment is still "in flight" —
      // that in-flight moment is what this test needs to observe.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Processing payment'), findsOneWidget);

      // A system back while still processing must not pop the route.
      // `pump()`, not `pumpAndSettle()`: the progress bar's
      // TweenAnimationBuilder keeps scheduling frames until it finishes,
      // so settling here would run the clock straight past the "still
      // processing" moment this assertion needs to catch.
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.text('Processing payment'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Payment successful'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('open payment'), findsOneWidget);
    },
  );

  testWidgets('View Booking on success replaces the stack with confirmation', (
    tester,
  ) async {
    final booking = _booking();
    final router = GoRouter(
      initialLocation: '/payment',
      routes: [
        GoRoute(
          path: '/payment',
          builder: (context, state) => PaymentScreen(
            booking: booking,
            processingDuration: const Duration(milliseconds: 200),
          ),
        ),
        GoRoute(
          path: '/booking-confirmed',
          builder: (context, state) {
            final confirmed = state.extra! as Booking;
            return Scaffold(body: Text('confirmed: ${confirmed.bookingId}'));
          },
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Booking'));
    await tester.pumpAndSettle();

    expect(find.text('confirmed: ${booking.bookingId}'), findsOneWidget);
    // Replaced, not pushed: nothing to pop back to the payment screen.
    expect(find.text('Payment successful'), findsNothing);
  });
}
