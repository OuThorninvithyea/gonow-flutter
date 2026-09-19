import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gonow/models/booking.dart';
import 'package:gonow/models/rental_plan.dart';
import 'package:gonow/models/vehicle_listing.dart';
import 'package:gonow/screens/booking/booking_confirmed_screen.dart';

Booking _booking() {
  final start = DateTime(2026, 1, 1, 14, 30);
  return Booking(
    vehicle: vehicleListings.first,
    plan: RentalPlan.weekly,
    start: start,
    end: start.add(RentalPlan.weekly.duration),
    bookingId: 'GN-BK-1024',
  );
}

Widget _wrap(Booking booking) {
  final router = GoRouter(
    initialLocation: '/confirmed',
    routes: [
      GoRoute(
        path: '/confirmed',
        builder: (context, state) => BookingConfirmedScreen(booking: booking),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) {
          final vehicle = state.extra! as VehicleListing;
          // The route only needs to prove the right vehicle arrived; the
          // map screen itself is covered by its own tests.
          return Scaffold(body: Text('map screen for ${vehicle.code}'));
        },
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  testWidgets('renders the booking id, vehicle, schedule and paid total', (
    tester,
  ) async {
    final booking = _booking();
    await tester.pumpWidget(_wrap(booking));

    expect(find.text('Booking Confirmed'), findsOneWidget);
    expect(find.text(booking.bookingId), findsOneWidget);
    expect(find.text(booking.vehicle.code), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('KHQR'), findsOneWidget);
    expect(find.text(booking.formattedTotal), findsOneWidget);
    expect(find.text('Start Navigation'), findsOneWidget);
    expect(find.text('View Booking'), findsOneWidget);
  });

  testWidgets('Copy puts the booking id on the clipboard', (tester) async {
    // The platform Clipboard channel has no default test handler, so
    // Clipboard.setData's future never resolves without one — mock it.
    final messages = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          messages.add(call.arguments['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    final booking = _booking();
    await tester.pumpWidget(_wrap(booking));

    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();

    expect(messages, [booking.bookingId]);
    expect(find.text('Booking ID copied.'), findsOneWidget);
  });

  testWidgets('Start Navigation opens the map screen for the booked vehicle', (
    tester,
  ) async {
    final booking = _booking();
    await tester.pumpWidget(_wrap(booking));

    await tester.tap(find.text('Start Navigation'));
    await tester.pumpAndSettle();

    expect(find.text('map screen for ${booking.vehicle.code}'), findsOneWidget);
  });

  testWidgets('View Booking is wired, not a dead tap', (tester) async {
    await tester.pumpWidget(_wrap(_booking()));

    await tester.tap(find.text('View Booking'));
    await tester.pump();

    expect(find.textContaining('coming soon'), findsOneWidget);
  });
}
