import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/rental_plan.dart';
import '../../models/rental_record.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bottom_nav.dart';

/// "Profile" — Figma `ProfileScreen` (node 592:906), reached from the
/// bottom nav's "Profile" tab.
///
/// The Figma frame is entirely static demo data (Sokha Chan, ABA / KHQR,
/// two saved locations, three notification toggles). This wires it to real
/// app state where that state already exists (name/email from
/// [AuthProvider], plan from [RentalPlan.daily], month total from
/// [rentalHistory]) and keeps the rest as sensible mock content the same
/// way the rest of the app's "settings-style" rows do — everything is a
/// real button, nothing is a dead tap.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // The Figma frame doesn't specify which toggles start on/off beyond their
  // visual state — "Promotions" is drawn in the off/light track, the other
  // two in the on/dark track. Kept as local UI state; no backend to persist
  // preferences to yet.
  bool _bookingConfirmations = true;
  bool _returnReminders = true;
  bool _promotions = false;

  void _comingSoon(String what) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$what is coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = user?.fullName ?? 'Rider';
    final email = user?.email ?? user?.phone ?? 'Not signed in';
    final initials = _initialsOf(name);

    final now = DateTime.now();
    final ridesThisMonth = rentalHistory.where(
      (r) => r.start.year == now.year && r.start.month == now.month,
    );

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.onDark,
          ),
        ),
      ),
      body: Column(
        children: [
          _Header(
            name: name,
            email: email,
            initials: initials,
            onBack: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CurrentPlanCard(
                    plan: RentalPlan.daily,
                    onChangePlan: () => _comingSoon('Changing plans'),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    label: 'Payment methods',
                    actionLabel: 'Add payment method',
                    onAction: () => _comingSoon('Adding a payment method'),
                  ),
                  const SizedBox(height: 8),
                  const _PaymentMethodsCard(),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    label: 'Rental history',
                    actionLabel: 'View all',
                    onAction: () => context.push('/rentals'),
                  ),
                  const SizedBox(height: 8),
                  if (ridesThisMonth.isEmpty)
                    const _EmptyRow(text: 'No rides yet this month.')
                  else
                    _RentalHistoryPreviewCard(
                      rides: ridesThisMonth.toList(),
                    ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    label: 'Saved locations',
                    actionLabel: 'Edit',
                    onAction: () => _comingSoon('Editing saved locations'),
                  ),
                  const SizedBox(height: 8),
                  const _SavedLocationsCard(),
                  const SizedBox(height: 24),
                  const _SectionLabel('Notifications & reminders'),
                  const SizedBox(height: 8),
                  _NotificationTogglesCard(
                    bookingConfirmations: _bookingConfirmations,
                    returnReminders: _returnReminders,
                    promotions: _promotions,
                    onBookingConfirmationsChanged: (v) =>
                        setState(() => _bookingConfirmations = v),
                    onReturnRemindersChanged: (v) =>
                        setState(() => _returnReminders = v),
                    onPromotionsChanged: (v) =>
                        setState(() => _promotions = v),
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('Emergency contact'),
                  const SizedBox(height: 8),
                  const _EmergencyContactCard(),
                  const SizedBox(height: 24),
                  const _SectionLabel('Account & support'),
                  const SizedBox(height: 8),
                  _AccountSupportCard(onTapRow: _comingSoon),
                  const SizedBox(height: 24),
                  Center(
                    child: Semantics(
                      button: true,
                      label: 'Log out',
                      child: GestureDetector(
                        onTap: () {
                          context.read<AuthProvider>().logout();
                          context.go('/login');
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Text(
                            'Log out',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.profileLogoutText,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.profileLogoutText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.profile,
        onTap: (tab) {
          if (tab == AppNavTab.profile) return;
          if (tab == AppNavTab.home) {
            context.canPop() ? context.pop() : context.go('/home');
            return;
          }
          if (tab == AppNavTab.map) {
            context.push('/map');
            return;
          }
          if (tab == AppNavTab.rentals) {
            context.push('/rentals');
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

/// "Sokha Chan" → "SC". Falls back to a single "?" the same way the home
/// screen's avatar does for an empty name.
String _initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  final letters = parts.take(2).map((p) => p[0].toUpperCase());
  return letters.join();
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.email,
    required this.initials,
    required this.onBack,
  });

  final String name;
  final String email;
  final String initials;
  final VoidCallback onBack;

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
                    child: const Text(
                      '←',
                      style: TextStyle(fontSize: 24, color: AppColors.onDark),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1,
                            color: AppColors.onDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onDarkMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.profileVerifiedChipBg,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '✓',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Phone verified',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.profileVerifiedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.plan, required this.onChangePlan});

  final RentalPlan plan;
  final VoidCallback onChangePlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120C0C0D),
            offset: Offset(0, 8),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT PLAN',
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
                  plan.title,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 32 / 24,
                    letterSpacing: -1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Active rental plan',
                  style: TextStyle(fontSize: 12, color: AppColors.dialogBody),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Change plan',
            child: GestureDetector(
              onTap: onChangePlan,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.termsChipBg,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Change plan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.actionLabel,
    required this.onAction,
  });

  final String label;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SectionLabel(label)),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: actionLabel,
          child: GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        height: 16.5 / 11,
        letterSpacing: 1.76,
        fontWeight: FontWeight.w600,
        color: AppColors.historySectionLabel,
      ),
    );
  }
}

class _PaymentMethodsCard extends StatelessWidget {
  const _PaymentMethodsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.profilePaymentIconBg,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ABA / KHQR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Primary payment method',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.historyStatLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.profileDefaultBadgeBg,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.profileDefaultBadgeText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0.75, color: AppColors.receiptDivider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceTile,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '\$',
                    style: TextStyle(fontSize: 12, color: AppColors.ink),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Fallback only',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.profileRowSubtextMuted,
                        ),
                      ),
                    ],
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

class _RentalHistoryPreviewCard extends StatelessWidget {
  const _RentalHistoryPreviewCard({required this.rides});

  /// Most recent-first, capped to the top 3 the way the Figma frame shows.
  final List<RentalRecord> rides;

  @override
  Widget build(BuildContext context) {
    final sorted = [...rides]..sort((a, b) => b.start.compareTo(a.start));
    final shown = sorted.take(3).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0)
              const Divider(height: 0.75, color: AppColors.receiptDivider),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 19,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${shown[i].start.day} '
                                '${_month(shown[i].start.month)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          TextSpan(
                            text: '   ${shown[i].durationMinutes} min',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.historyStatLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    shown[i].formattedAmount,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _month(int month) => _months[month - 1];
}

class _SavedLocationsCard extends StatelessWidget {
  const _SavedLocationsCard();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _LocationRow(label: 'Work', address: 'BKK1, Phnom Penh'),
        SizedBox(height: 1),
        _LocationRow(label: 'Home', address: 'BKK1, Phnom Penh'),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.label, required this.address});

  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.historyStatLabel,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.historyStatLabel,
          ),
        ],
      ),
    );
  }
}

class _NotificationTogglesCard extends StatelessWidget {
  const _NotificationTogglesCard({
    required this.bookingConfirmations,
    required this.returnReminders,
    required this.promotions,
    required this.onBookingConfirmationsChanged,
    required this.onReturnRemindersChanged,
    required this.onPromotionsChanged,
  });

  final bool bookingConfirmations;
  final bool returnReminders;
  final bool promotions;
  final ValueChanged<bool> onBookingConfirmationsChanged;
  final ValueChanged<bool> onReturnRemindersChanged;
  final ValueChanged<bool> onPromotionsChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _ToggleRow(
            title: 'Booking confirmations',
            subtitle: 'Payment and booking updates',
            value: bookingConfirmations,
            onChanged: onBookingConfirmationsChanged,
          ),
          const Divider(height: 0.75, color: AppColors.receiptDivider),
          _ToggleRow(
            title: 'Return reminders',
            subtitle: 'Avoid late return fees',
            value: returnReminders,
            onChanged: onReturnRemindersChanged,
          ),
          const Divider(height: 0.75, color: AppColors.receiptDivider),
          _ToggleRow(
            title: 'Promotions',
            subtitle: 'Occasional offers from GoNow',
            value: promotions,
            onChanged: onPromotionsChanged,
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.historyStatLabel,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            toggled: value,
            label: title,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.ink,
              activeThumbColor: AppColors.surface,
              inactiveTrackColor: AppColors.receiptCardBorder,
              inactiveThumbColor: AppColors.surface,
              trackOutlineColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContactCard extends StatefulWidget {
  const _EmergencyContactCard();

  @override
  State<_EmergencyContactCard> createState() => _EmergencyContactCardState();
}

class _EmergencyContactCardState extends State<_EmergencyContactCard> {
  late final TextEditingController _controller = TextEditingController(
    text: '+855 12 456 789',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.termsChipBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Used by GoNow emergency support during an active ride.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.profileEmergencyBody,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Trusted contact number',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.profileInputBorder),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSupportCard extends StatelessWidget {
  const _AccountSupportCard({required this.onTapRow});

  final ValueChanged<String> onTapRow;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Edit name, email & phone', null),
      ('Change password', null),
      ('Language', 'English · ខ្មែរ'),
      ('Contact GoNow support', null),
      ('FAQ', null),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(height: 0.75, color: AppColors.receiptDivider),
            Semantics(
              button: true,
              label: rows[i].$1,
              child: GestureDetector(
                onTap: () => onTapRow(rows[i].$1),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rows[i].$1,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            if (rows[i].$2 != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                rows[i].$2!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.historyStatLabel,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.historyStatLabel,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: AppColors.inkSoft)),
    );
  }
}
