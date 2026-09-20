import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';

/// "Processing payment" → "Payment successful" — Figma "payment-flow"
/// section, nodes 90:1323 and 90:1651. Both are small floating cards (not
/// full 431pt frames like the rest of the flow), so this screen renders
/// them as a centered dialog card over the canvas background.
///
/// There is no real payment gateway yet — [_processingDuration] simulates
/// the KHQR charge the Figma "Paid · KHQR" badge on the next screen refers
/// to, then flips to the success state.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.booking,
    this.processingDuration = const Duration(seconds: 2),
  });

  final Booking booking;

  /// Exposed for tests — production always uses the default.
  final Duration processingDuration;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _succeeded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.processingDuration, () {
      if (!mounted) return;
      setState(() => _succeeded = true);
    });
  }

  void _viewBooking() {
    // Replaces the whole stack (plan → summary → payment) so the back
    // button from the confirmation screen doesn't walk the rider back
    // through a payment that has already gone through.
    context.go('/booking-confirmed', extra: widget.booking);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // The charge is already "in flight" the moment this screen opens —
      // let the rider dismiss the success card, but not walk back out of
      // an in-progress payment.
      canPop: _succeeded,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          backgroundColor: AppColors.canvas,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Payment',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _succeeded
                  ? _SuccessCard(onViewBooking: _viewBooking)
                  : _ProcessingCard(duration: widget.processingDuration),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogCard extends StatelessWidget {
  const _DialogCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _ProcessingCard extends StatelessWidget {
  const _ProcessingCard({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return _DialogCard(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.ink.withValues(alpha: 0.63),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            '…',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Processing payment',
          style: TextStyle(
            fontSize: 27,
            height: 1.5,
            letterSpacing: -1.35,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Securely confirming your payment. This usually takes a few '
          'seconds.',
          style: TextStyle(
            fontSize: 14,
            height: 24 / 14,
            color: AppColors.dialogBody,
          ),
        ),
        const SizedBox(height: 28),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            height: 6,
            width: double.infinity,
            child: Stack(
              children: [
                Container(color: AppColors.progressTrack),
                // Animates across the whole wait so the bar always finishes
                // right as [PaymentScreen] flips to the success card,
                // rather than a static mock fraction.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: duration,
                  curve: Curves.easeInOut,
                  builder: (context, value, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: Container(
                      color: AppColors.primary.withValues(alpha: 0.63),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.onViewBooking});

  final VoidCallback onViewBooking;

  @override
  Widget build(BuildContext context) {
    return _DialogCard(
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
          'Payment successful',
          style: TextStyle(
            fontSize: 27,
            height: 1.5,
            letterSpacing: -1.35,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your ride has been paid for and is ready when you are.',
          style: TextStyle(
            fontSize: 14,
            height: 24 / 14,
            color: AppColors.dialogBody,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onViewBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.onDark,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'View Booking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
