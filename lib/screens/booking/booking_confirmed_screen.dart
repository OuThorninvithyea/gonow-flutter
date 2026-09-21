import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../models/booking.dart';
import '../../models/vehicle_listing.dart';

/// "Booking Confirmed" — Figma "payment-flow" section, `comfirm-booking`
/// frame (182:344). Terminal screen of the payment flow: the rider has
/// paid and just needs the booking ID and a way back to the fleet.
///
/// Reached via `context.go`, replacing the whole plan → summary → payment
/// stack, so the device back button from here exits toward `/home` rather
/// than re-opening a completed payment.
class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.onDark,
          ),
        ),
      ),
      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BookingIdCard(bookingId: booking.bookingId),
                  const SizedBox(height: 16),
                  _VehicleCard(vehicle: booking.vehicle),
                  const SizedBox(height: 16),
                  _RentalPeriodCard(booking: booking),
                  const SizedBox(height: 16),
                  _PaymentStatusCard(booking: booking),
                ],
              ),
            ),
          ),
          _BottomActions(
            onViewBooking: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking details are coming soon.')),
            ),
            onStartNavigation: () =>
                context.push<void>('/map', extra: booking.vehicle),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.ink,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check,
                  size: 30,
                  color: AppColors.successCheckDark,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Booking Confirmed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  height: 1,
                  letterSpacing: -1.76,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your scooter is reserved and ready.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.onDarkSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingIdCard extends StatelessWidget {
  const _BookingIdCard({required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BOOKING ID',
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              letterSpacing: 1.76,
              fontWeight: FontWeight.w600,
              color: AppColors.onDarkChip,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bookingId,
                style: const TextStyle(
                  fontSize: 20,
                  height: 28 / 20,
                  letterSpacing: -0.6,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onDark,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: bookingId));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking ID copied.')),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTile,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Copy',
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Use this code when contacting support.',
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              color: AppColors.onDarkChip,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});

  final VehicleListing vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 112,
            height: 76,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceTile,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: -20,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/home/scooter.png',
                  width: 112,
                  height: 76,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ELECTRIC SCOOTER',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    letterSpacing: 1.76,
                    fontWeight: FontWeight.w600,
                    color: AppColors.planLabel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.code,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 28 / 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.receiptLocation,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        vehicle.location,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          color: AppColors.receiptLocation,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RentalPeriodCard extends StatelessWidget {
  const _RentalPeriodCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rental period',
            style: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          const _DashedRule(),
          const SizedBox(height: 16),
          _DetailRow(label: 'Rental plan', value: booking.plan.title),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Starts',
            value: formatRentalDateTime(booking.start),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'Return', value: formatRentalDateTime(booking.end)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            height: 20 / 14,
            color: AppColors.planLabel,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class _PaymentStatusCard extends StatelessWidget {
  const _PaymentStatusCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment status',
                style: TextStyle(fontSize: 12, color: AppColors.onDarkChip),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Paid',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'KHQR',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Total paid',
                style: TextStyle(fontSize: 12, color: AppColors.onDarkChip),
              ),
              const SizedBox(height: 4),
              Text(
                booking.formattedTotal,
                style: const TextStyle(
                  fontSize: 24,
                  height: 32 / 24,
                  letterSpacing: -0.96,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onViewBooking,
    required this.onStartNavigation,
  });

  final VoidCallback onViewBooking;
  final VoidCallback onStartNavigation;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onStartNavigation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Start Navigation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: onViewBooking,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border, width: 0.7),
                  foregroundColor: AppColors.ink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'View Booking',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashed hairline separator — same painter as the other payment-flow
/// screens; see [BookingSummaryScreen]'s copy for why it isn't shared yet.
class _DashedRule extends StatelessWidget {
  const _DashedRule();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashedRulePainter()),
    );
  }
}

class _DashedRulePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.planDivider
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 4.0;
    for (double x = 0; x < size.width; x += dash + gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset((x + dash).clamp(0, size.width), 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
