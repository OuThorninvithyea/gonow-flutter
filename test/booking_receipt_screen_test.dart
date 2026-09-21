import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gonow/models/booking.dart';
import 'package:gonow/models/rental_plan.dart';
import 'package:gonow/models/vehicle_listing.dart';
import 'package:gonow/screens/booking/booking_receipt_screen.dart';

Booking _booking() {
  final start = DateTime(2026, 9, 14, 10, 22);
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
    initialLocation: '/receipt',
    routes: [
      GoRoute(
        path: '/receipt',
        builder: (context, state) => BookingReceiptScreen(booking: booking),
      ),
      GoRoute(
        path: '/back-target',
        builder: (context, state) =>
            const Scaffold(body: Text('previous screen')),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  testWidgets(
    'renders the payment total, booking id, rental details and summary',
    (tester) async {
      final booking = _booking();
      await tester.pumpWidget(_wrap(booking));

      expect(find.text('Payment receipt'), findsOneWidget);
      expect(find.text('PAYMENT RECEIVED'), findsOneWidget);
      expect(find.text(booking.formattedTotal), findsWidgets);
      expect(find.text(booking.bookingId), findsOneWidget);

      expect(find.text('Rental details'), findsOneWidget);
      expect(find.text(booking.vehicle.code), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text(booking.vehicle.location), findsOneWidget);
      expect(find.text('14 Sep 2026'), findsOneWidget);

      expect(find.text('Payment summary'), findsOneWidget);
      expect(find.text('Rental charge'), findsOneWidget);
      expect(find.text(booking.formattedRentalPrice), findsOneWidget);
      expect(find.text('Service fee'), findsOneWidget);
      expect(find.text(booking.formattedServiceFee), findsOneWidget);
      expect(find.text('Total paid'), findsOneWidget);
      expect(find.text('ABA / KHQR'), findsOneWidget);
      expect(find.text('Download receipt'), findsOneWidget);
    },
  );

  testWidgets('Download receipt says it is coming soon, not a dead tap', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_booking()));

    final downloadFinder = find.text('Download receipt');
    await tester.ensureVisible(downloadFinder);
    await tester.tap(downloadFinder);
    await tester.pump();

    expect(find.textContaining('coming soon'), findsOneWidget);
  });

  testWidgets('the back control pops to the previous screen', (tester) async {
    final router = GoRouter(
      initialLocation: '/back-target',
      routes: [
        GoRoute(
          path: '/back-target',
          builder: (context, state) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => context.push('/receipt', extra: _booking()),
                child: const Text('open receipt'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/receipt',
          builder: (context, state) =>
              BookingReceiptScreen(booking: state.extra! as Booking),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('open receipt'));
    await tester.pumpAndSettle();
    expect(find.text('Payment receipt'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('open receipt'), findsOneWidget);
  });

  for (final size in const [Size(360, 640), Size(431, 996), Size(320, 568)]) {
    testWidgets('renders without overflow at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(_booking()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
