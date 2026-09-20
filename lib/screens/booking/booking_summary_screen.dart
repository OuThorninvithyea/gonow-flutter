import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../models/booking.dart';
import '../../models/vehicle_listing.dart';

/// "Booking summary." — Figma "payment-flow" section, `total-recipt` frame
/// (90:903 unchecked / 117:707 checked). The receipt cards mirror the
/// rental-plan screen's schedule card; the new pieces here are the price
/// breakdown and the terms gate on "Continue to Payment".
///
/// This screen only confirms *what* is being paid for — the actual charge
/// happens on the next screen (processing → booking confirmed), which is
/// why the CTA reads "Continue to Payment" rather than "Pay now".
class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key, required this.booking});

  final Booking booking;

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _agreed = false;

  Future<void> _continueToPayment() async {
    if (!_agreed) return;
    await context.push<void>('/payment', extra: widget.booking);
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final vehicle = booking.vehicle;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          _Header(onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _VehicleCard(vehicle: vehicle),
                  const SizedBox(height: 16),
                  _RentalDetailsCard(
                    booking: booking,
                    onEdit: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: 16),
                  _PriceBreakdownCard(booking: booking),
                  const SizedBox(height: 25),
                  _TermsCheckbox(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _agreed ? _continueToPayment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: AppColors.onDark,
                    disabledBackgroundColor: AppColors.ink.withValues(
                      alpha: 0.4,
                    ),
                    disabledForegroundColor: AppColors.onDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continue to Payment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.ink,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                button: true,
                label: 'Back',
                child: GestureDetector(
                  onTap: onBack,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0x1FFFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: AppColors.onDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'ONE LAST CHECK',
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  letterSpacing: 2.16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Booking\nsummary.',
                style: TextStyle(
                  fontSize: 34,
                  height: 1,
                  letterSpacing: -1.87,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onDark,
                ),
              ),
            ],
          ),
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scooter',
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
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
                    const SizedBox(height: 4),
                    Text(
                      vehicle.location,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: AppColors.receiptMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 96,
                height: 80,
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
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/home/scooter.png',
                      width: 96,
                      height: 64,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _DashedRule(),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                icon: Icons.bolt,
                label: '${vehicle.batteryPercent}% battery',
              ),
              const SizedBox(width: 8),
              _StatChip(label: vehicle.range),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({this.icon, required this.label});

  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.receiptChip,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.ink),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              height: 16 / 12,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _RentalDetailsCard extends StatelessWidget {
  const _RentalDetailsCard({required this.booking, required this.onEdit});

  final Booking booking;
  final VoidCallback onEdit;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rental details',
                style: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.receiptCardBorder,
                      width: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Edit booking',
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

class _PriceBreakdownCard extends StatelessWidget {
  const _PriceBreakdownCard({required this.booking});

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
            'Price breakdown',
            style: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          _PriceRow(label: 'Rental price', value: booking.formattedRentalPrice),
          const SizedBox(height: 12),
          _PriceRow(label: 'Service fee', value: booking.formattedServiceFee),
          const SizedBox(height: 12),
          _PriceRow(
            label: 'Refundable deposit',
            value: booking.formattedDeposit,
          ),
          const SizedBox(height: 12),
          const _DashedRule(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  height: 28 / 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Text(
                booking.formattedTotal,
                style: const TextStyle(
                  fontSize: 18,
                  height: 28 / 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});

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
            color: AppColors.receiptMuted,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            height: 20 / 14,
            color: AppColors.receiptMuted,
          ),
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: value,
      label: 'I agree to the rental and safety terms.',
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.termsChipBg,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: value ? AppColors.ink : AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: value ? AppColors.ink : AppColors.checkboxBorder,
                    width: 1,
                  ),
                ),
                child: value
                    ? const Icon(Icons.check, size: 14, color: AppColors.onDark)
                    : null,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'I agree to the rental and safety terms.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashed hairline separator — Flutter has no dashed border, so paint it.
/// Duplicated from [RentalPlanScreen]'s private one; both screens are
/// small enough that extracting a shared widget isn't worth the indirection
/// yet, but promote it if a third screen needs it.
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
