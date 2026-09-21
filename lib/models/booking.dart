import '../models/rental_plan.dart';
import '../models/vehicle_listing.dart';

class Booking {
  const Booking({
    required this.vehicle,
    required this.plan,
    required this.start,
    required this.end,
    required this.bookingId,
  });

  final VehicleListing vehicle;
  final RentalPlan plan;
  final DateTime start;
  final DateTime end;

  /// Short reference shown on the confirmation screen, e.g. "GN-BK-1024".
  final String bookingId;

  // --- Figma "Price breakdown" (90:979 / 179:753) — mock fixed fees on
  // top of the plan's own price, since GoNow has no live pricing API yet.
  static const double serviceFee = 1;
  static const double refundableDeposit = 0;

  double get rentalPrice => double.parse(plan.amount.replaceFirst(r'$', ''));

  double get total => rentalPrice + serviceFee + refundableDeposit;

  String get formattedRentalPrice => _money(rentalPrice);
  String get formattedServiceFee => _money(serviceFee);
  String get formattedDeposit => _money(refundableDeposit);
  String get formattedTotal => _money(total);

  static String _money(double value) => '\$${value.toStringAsFixed(2)}';
}
