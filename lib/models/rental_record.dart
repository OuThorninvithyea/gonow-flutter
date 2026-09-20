import 'package:intl/intl.dart';

import 'vehicle_listing.dart';

/// One completed ride shown on the "Rental history" screen (Figma
/// `RentalHistoryScreen`, node 594:409).
///
/// Unlike [Booking] (an upcoming, unpaid rental moving through the payment
/// flow), a [RentalRecord] is a finished, already-paid trip — there's no
/// plan/schedule to carry, just what happened and what it cost.
class RentalRecord {
  const RentalRecord({
    required this.id,
    required this.vehicle,
    required this.route,
    required this.start,
    required this.durationMinutes,
    required this.amount,
  });

  final String id;
  final VehicleListing vehicle;

  /// "BKK1 → Wat Phnom" — pickup and drop-off, exactly as Figma shows it.
  final String route;

  final DateTime start;
  final int durationMinutes;
  final double amount;

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  /// "14 Sep 2026 · 10:22 AM · 28 min", matching the Figma copy format.
  String get formattedSummary =>
      '${DateFormat('d MMM yyyy').format(start)} · '
      '${DateFormat('h:mm a').format(start)} · $durationMinutes min';
}

/// Mock ride history — swap for a real API call once bookings are tracked
/// server-side. Fixed dates rather than `DateTime.now()`-relative ones: this
/// is demo data for a "past rides" screen, so it should read like real
/// history regardless of when the app happens to run, the same way the mock
/// fleet's battery/range numbers are fixed rather than live.
///
/// September's four rides total exactly $13.20 and August's two total
/// $5.70 — the [RentalHistoryScreen] summary card sums whatever month is
/// selected, so these numbers must stay in sync with the screen's mock
/// summary expectations covered by tests.
///
/// Not `const`: each record references a [vehicleListings] entry by index,
/// and list-index reads aren't constant expressions in Dart.
final rentalHistory = <RentalRecord>[
  RentalRecord(
    id: 'ride-2026-09-18',
    vehicle: vehicleListings[0],
    route: 'BKK1 → Wat Phnom',
    start: DateTime(2026, 9, 18, 10, 22),
    durationMinutes: 28,
    amount: 3.10,
  ),
  RentalRecord(
    id: 'ride-2026-09-15',
    vehicle: vehicleListings[1],
    route: 'Riverside → BKK1',
    start: DateTime(2026, 9, 15, 8, 5),
    durationMinutes: 22,
    amount: 2.80,
  ),
  RentalRecord(
    id: 'ride-2026-09-10',
    vehicle: vehicleListings[2],
    route: 'Olympic Market → Toul Kork',
    start: DateTime(2026, 9, 10, 17, 40),
    durationMinutes: 35,
    amount: 3.90,
  ),
  RentalRecord(
    id: 'ride-2026-09-04',
    vehicle: vehicleListings[0],
    route: 'Wat Phnom → Riverside',
    start: DateTime(2026, 9, 4, 19, 15),
    durationMinutes: 25,
    amount: 3.40,
  ),
  RentalRecord(
    id: 'ride-2026-08-28',
    vehicle: vehicleListings[3],
    route: 'Toul Kork → BKK1',
    start: DateTime(2026, 8, 28, 9, 0),
    durationMinutes: 30,
    amount: 3.50,
  ),
  RentalRecord(
    id: 'ride-2026-08-20',
    vehicle: vehicleListings[1],
    route: 'BKK1 → Olympic Market',
    start: DateTime(2026, 8, 20, 14, 12),
    durationMinutes: 18,
    amount: 2.20,
  ),
];
