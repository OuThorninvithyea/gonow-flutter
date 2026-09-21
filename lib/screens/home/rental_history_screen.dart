import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/rental_record.dart';
import '../../widgets/app_bottom_nav.dart';

/// "Rental history" — Figma `RentalHistoryScreen` (node 594:409), reached
/// from the bottom nav's "Rentals" tab.
///
/// The Figma frame shows one month (September) with a running summary card
/// above the list. Real usage needs more than one month of history to be
/// useful, so this adds a month picker the static design doesn't have —
/// everything else (summary card, "Recent rentals" list, receipt rows)
/// matches the frame directly.
class RentalHistoryScreen extends StatefulWidget {
  const RentalHistoryScreen({super.key});

  @override
  State<RentalHistoryScreen> createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends State<RentalHistoryScreen> {
  late final List<DateTime> _months = _monthsWithRides();
  late int _monthIndex = 0;

  List<DateTime> _monthsWithRides() {
    final seen = <DateTime>{};
    for (final ride in rentalHistory) {
      seen.add(DateTime(ride.start.year, ride.start.month));
    }
    final months = seen.toList()..sort((a, b) => b.compareTo(a));
    return months;
  }

  DateTime get _selectedMonth =>
      _months.isEmpty ? DateTime.now() : _months[_monthIndex];

  List<RentalRecord> get _ridesInSelectedMonth {
    final rides = rentalHistory
        .where(
          (r) =>
              r.start.year == _selectedMonth.year &&
              r.start.month == _selectedMonth.month,
        )
        .toList();
    rides.sort((a, b) => b.start.compareTo(a.start));
    return rides;
  }

  Future<void> _pickMonth() async {
    if (_months.length < 2) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _MonthPickerSheet(months: _months, selectedIndex: _monthIndex),
    );
    if (picked == null || !mounted) return;
    setState(() => _monthIndex = picked);
  }

  @override
  Widget build(BuildContext context) {
    final rides = _ridesInSelectedMonth;
    final totalSpent = rides.fold<double>(0, (sum, r) => sum + r.amount);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Rental History',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.onDark,
          ),
        ),
      ),
      body: Column(
        children: [
          _Header(
            onBack: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryCard(
                    month: _selectedMonth,
                    rideCount: rides.length,
                    totalSpent: totalSpent,
                  ),
                  const SizedBox(height: 25),
                  _SectionHeader(
                    month: _selectedMonth,
                    changeable: _months.length > 1,
                    onTap: _pickMonth,
                  ),
                  const SizedBox(height: 20),
                  if (rides.isEmpty)
                    const _EmptyState()
                  else
                    for (final ride in rides) ...[
                      _RideRow(ride: ride),
                      if (ride != rides.last) const Divider(height: 1),
                    ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.rentals,
        onTap: (tab) {
          if (tab == AppNavTab.rentals) return;
          if (tab == AppNavTab.home) {
            context.canPop() ? context.pop() : context.go('/home');
            return;
          }
          if (tab == AppNavTab.map) {
            context.push('/map');
            return;
          }
          if (tab == AppNavTab.saved) {
            context.push('/saved');
            return;
          }
          if (tab == AppNavTab.profile) {
            context.push('/profile');
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The ${tab.name} tab is coming soon.')),
          );
        },
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.inkBorder,
                        width: 0.7,
                      ),
                    ),
                    alignment: Alignment.center,
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
                'YOUR RIDING RECORD',
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
                'Rental history',
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.month,
    required this.rideCount,
    required this.totalSpent,
  });

  final DateTime month;
  final int rideCount;
  final double totalSpent;

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
          Text(
            DateFormat.yMMMM().format(month).toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              height: 16.5 / 11,
              letterSpacing: 1.76,
              fontWeight: FontWeight.w600,
              color: AppColors.planLabel,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  value: '$rideCount ride${rideCount == 1 ? '' : 's'}',
                  label: 'This month',
                  alignEnd: false,
                ),
              ),
              Container(
                width: 0.75,
                height: 52,
                color: AppColors.receiptDivider,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _Stat(
                  value: '\$${totalSpent.toStringAsFixed(2)}',
                  label: 'Total spent',
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.alignEnd,
  });

  final String value;
  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            height: 32 / 24,
            letterSpacing: -1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            height: 16 / 12,
            color: AppColors.historyStatLabel,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.month,
    required this.changeable,
    required this.onTap,
  });

  final DateTime month;
  final bool changeable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'RECENT RENTALS',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 16.5 / 11,
              letterSpacing: 1.76,
              fontWeight: FontWeight.w600,
              color: AppColors.historySectionLabel,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (changeable)
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.termsChipBg,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '${DateFormat.MMMM().format(month)} ⌄',
                style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
          )
        else
          Text(
            DateFormat.MMMM().format(month),
            style: const TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
      ],
    );
  }
}

class _RideRow extends StatelessWidget {
  const _RideRow({required this.ride});

  final RentalRecord ride;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open details for ${ride.vehicle.code}',
      child: GestureDetector(
        onTap: () => _showReceipt(context),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(19),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/home/scooter.png',
                  width: 38,
                  height: 38,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.route,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ride.formattedSummary,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        color: AppColors.historyStatLabel,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ride.formattedAmount,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Receipt',
                    style: TextStyle(
                      fontSize: 10,
                      height: 15 / 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.historyReceiptLink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReceipt(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReceiptSheet(ride: ride),
    );
  }
}

class _ReceiptSheet extends StatelessWidget {
  const _ReceiptSheet({required this.ride});

  final RentalRecord ride;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              ride.route,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ride.formattedSummary,
              style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 20),
            _ReceiptLine(label: 'Vehicle', value: ride.vehicle.code),
            const SizedBox(height: 12),
            _ReceiptLine(label: 'Amount paid', value: ride.formattedAmount),
            const SizedBox(height: 12),
            _ReceiptLine(label: 'Payment method', value: 'KHQR'),
          ],
        ),
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.inkSoft)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'No rides this month.',
          style: TextStyle(color: AppColors.inkSoft),
        ),
      ),
    );
  }
}

class _MonthPickerSheet extends StatelessWidget {
  const _MonthPickerSheet({required this.months, required this.selectedIndex});

  final List<DateTime> months;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < months.length; i++)
              _MonthOption(
                label: DateFormat.yMMMM().format(months[i]),
                selected: i == selectedIndex,
                onTap: () => Navigator.of(context).pop(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthOption extends StatelessWidget {
  const _MonthOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: AppColors.ink),
              ),
              if (selected)
                const Icon(Icons.check, size: 20, color: AppColors.ink),
            ],
          ),
        ),
      ),
    );
  }
}
