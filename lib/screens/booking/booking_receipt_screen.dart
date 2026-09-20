import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';

/// "Payment receipt" — Figma "booking-receipt" frame (node 841:519), the
/// full-page receipt reached by tapping "View Booking" on the Booking
/// Confirmed screen.
///
/// Unlike [BookingConfirmedScreen] (a one-time celebratory terminal screen),
/// this is meant to be re-opened any time the rider wants to review or
/// "download" what they paid — so it stays on the navigation stack as a
/// normal pushed screen rather than replacing it.
///
/// All figures come straight off [Booking] (rental price, service fee,
/// total) — the Figma mock numbers ($5 rental + $1 fee = $6 total) are
/// exactly what a [Booking] on [RentalPlan.daily] already computes, so
/// nothing here is hardcoded.
class BookingReceiptScreen extends StatelessWidget {
  const BookingReceiptScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
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
                  _PaymentReceivedCard(booking: booking),
                  const SizedBox(height: 16),
                  _RentalDetailsCard(booking: booking),
                  const SizedBox(height: 16),
                  _PaymentSummaryCard(booking: booking),
                  const SizedBox(height: 16),
                  _DownloadReceiptButton(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Receipt download is coming soon.'),
                      ),
                    ),
                  ),
                ],
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
                'GONOW RECEIPT',
                style: TextStyle(
                  fontSize: 11,
                  height: 16.5 / 11,
                  letterSpacing: 1.98,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Payment receipt',
                style: TextStyle(
                  fontSize: 34,
                  height: 1,
                  letterSpacing: -2.04,
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

class _PaymentReceivedCard extends StatelessWidget {
  const _PaymentReceivedCard({required this.booking});

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
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.profileDefaultBadgeBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              size: 24,
              color: AppColors.receiptCheckGreen,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'PAYMENT RECEIVED',
            style: TextStyle(
              fontSize: 11,
              height: 16.5 / 11,
              letterSpacing: 1.76,
              fontWeight: FontWeight.w600,
              color: AppColors.planLabel,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.formattedTotal,
            style: const TextStyle(
              fontSize: 32,
              height: 1.5,
              letterSpacing: -1.92,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceTile,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              booking.bookingId,
              style: const TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontFamily: 'monospace',
                color: AppColors.textLink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RentalDetailsCard extends StatelessWidget {
  const _RentalDetailsCard({required this.booking});

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
            'Rental details',
            style: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 0.75, color: AppColors.receiptDivider),
          const SizedBox(height: 16),
          _DetailRow(label: 'Scooter', value: booking.vehicle.code),
          const SizedBox(height: 12),
          _DetailRow(label: 'Rental plan', value: booking.plan.title),
          const SizedBox(height: 12),
          _DetailRow(label: 'Pick-up', value: booking.vehicle.location),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Date',
            value: DateFormat('d MMM yyyy').format(booking.start),
          ),
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
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard({required this.booking});

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
            'Payment summary',
            style: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 0.75, color: AppColors.receiptDivider),
          const SizedBox(height: 16),
          _PriceRow(label: 'Rental charge', value: booking.formattedRentalPrice),
          const SizedBox(height: 12),
          _PriceRow(label: 'Service fee', value: booking.formattedServiceFee),
          const SizedBox(height: 12),
          const Divider(height: 0.75, color: AppColors.receiptDivider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total paid',
                style: TextStyle(
                  fontSize: 18,
                  height: 28 / 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Flexible(
                child: Text(
                  booking.formattedTotal,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 28 / 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.termsChipBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment method',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.textBody,
                  ),
                ),
                Flexible(
                  child: Text(
                    'ABA / KHQR',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
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
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: AppColors.receiptMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _DownloadReceiptButton extends StatelessWidget {
  const _DownloadReceiptButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Download receipt',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Download receipt',
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.download,
                  size: 16,
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
