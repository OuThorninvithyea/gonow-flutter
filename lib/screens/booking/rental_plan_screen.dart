import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../models/booking.dart';
import '../../models/rental_plan.dart';
import '../../models/vehicle_listing.dart';

class RentalPlanScreen extends StatefulWidget {
  const RentalPlanScreen({super.key, required this.vehicle});

  final VehicleListing vehicle;

  @override
  State<RentalPlanScreen> createState() => _RentalPlanScreenState();
}

class _RentalPlanScreenState extends State<RentalPlanScreen> {
  RentalPlan _plan = RentalPlan.daily;
  late DateTime _start;

  @override
  void initState() {
    super.initState();
    // Default to "now, rounded up to the next half hour" so the mock start
    // time is always in the future and reads cleanly (2:30 PM, not 2:07 PM).
    final now = DateTime.now();
    final minutes = now.minute <= 30 ? 30 : 60;
    _start = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ).add(Duration(minutes: minutes));
  }

  DateTime get _end => _start.add(_plan.duration);

  Future<void> _changeStart() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 180)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (time == null || !mounted) return;

    setState(() {
      _start = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _continue() {
    final booking = Booking(
      vehicle: widget.vehicle,
      plan: _plan,
      start: _start,
      end: _end,
      // Mock booking reference — a real backend would issue this.
      bookingId: 'GN-BK-${_start.millisecondsSinceEpoch % 10000}',
    );
    context.push<void>('/booking-summary', extra: booking);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Rental Plan',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.onDark,
          ),
        ),
      ),
      body: Column(
        children: [
          _Header(
            vehicleName: widget.vehicle.name,
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final plan in RentalPlan.values) ...[
                    _PlanCard(
                      plan: plan,
                      selected: plan == _plan,
                      onTap: () => setState(() => _plan = plan),
                    ),
                    if (plan != RentalPlan.values.last)
                      const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 28),
                  _ScheduleCard(
                    startLabel: formatRentalDateTime(_start),
                    returnLabel: formatRentalDateTime(_end),
                    onChange: _changeStart,
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'You can extend your rental in the app any time before '
                      'it ends.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: AppColors.planFootnote,
                      ),
                    ),
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
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: AppColors.onDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continue to booking',
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
  const _Header({required this.vehicleName, required this.onBack});

  final String vehicleName;
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
              Text(
                vehicleName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  letterSpacing: 2.16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose your\nrental plan.',
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final RentalPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.planBorder,
              width: 0.7,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? AppColors.ink : null,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.ink : AppColors.planRadioBorder,
                    width: 0.7,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 16, color: AppColors.onDark)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 24 / 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      plan.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: AppColors.planSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: plan.amount,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 28 / 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    TextSpan(
                      text: plan.unit,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.startLabel,
    required this.returnLabel,
    required this.onChange,
  });

  final String startLabel;
  final String returnLabel;
  final VoidCallback onChange;

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
                child: _Field(label: 'Starts', value: startLabel),
              ),
              GestureDetector(
                onTap: onChange,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.planChip,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Change',
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
          _Field(label: 'Return by', value: returnLabel),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            height: 16 / 12,
            color: AppColors.planLabel,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

/// Dashed hairline separator — Flutter has no dashed border, so paint it.
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
