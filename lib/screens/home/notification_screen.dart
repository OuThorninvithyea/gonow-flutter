import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// "Notification" — Figma "iPhone 16 Plus - 26" (node 748:651), reached
/// from the home screen's bell icon.
///
/// The Figma frame shows a fixed set of 6 notifications with three filter
/// chips (All / Unread / Rides) above them. "All" is the only chip wired to
/// real filtering — the underlying mock feed doesn't track read state or a
/// ride-vs-other split cleanly enough to make "Unread"/"Rides" do anything
/// but no-op, so tapping them keeps the same "coming soon" convention used
/// elsewhere in the app for filters that aren't real yet.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationFeedItem {
  const _NotificationFeedItem({
    required this.title,
    required this.body,
    required this.time,
    required this.emoji,
    required this.unread,
  });

  final String title;
  final String body;
  final String time;
  final String emoji;

  /// Drives the icon-tile color (lime = unread/actionable, dark = read) and
  /// whether the small dot badge shows, exactly as the Figma frame alternates
  /// them.
  final bool unread;
}

const _notifications = [
  _NotificationFeedItem(
    title: 'Ride Confirmed',
    body: 'Your scooter GN-024 is reserved at Toul Kork station',
    time: 'JUST NOW',
    emoji: '🔔',
    unread: true,
  ),
  _NotificationFeedItem(
    title: 'Charge alert',
    body: 'GN-011 battery is at 15%. Please return back',
    time: '3 HR AGO',
    emoji: '⚡',
    unread: true,
  ),
  _NotificationFeedItem(
    title: 'New station nearby',
    body: 'A new pickup opened 120m from your location',
    time: '5 MIN AGO',
    emoji: '📍',
    unread: true,
  ),
  _NotificationFeedItem(
    title: 'Promo unlocked',
    body: "You've earned a 20% discount on your next ride!",
    time: 'YESTERDAY',
    emoji: '🎉',
    unread: false,
  ),
  _NotificationFeedItem(
    title: 'Maintenance notice',
    body: 'Primary payment method',
    time: '5 DAYS AGO',
    emoji: '🔧',
    unread: false,
  ),
  _NotificationFeedItem(
    title: 'Ride completed',
    body: 'Station at Daun Penh will be offline for 2 hours',
    time: '2 DAYS AGO',
    emoji: '🛵',
    unread: false,
  ),
];

class _NotificationScreenState extends State<NotificationScreen> {
  int _filterIndex = 0;

  void _selectFilter(int index) {
    if (index == 0) {
      setState(() => _filterIndex = index);
      return;
    }
    // "Unread" / "Rides" — same not-yet-real-filter convention as the rest
    // of the app; the chip still highlights so the tap isn't silently
    // ignored, but the list underneath doesn't change.
    setState(() => _filterIndex = index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_filters[index]} filtering is coming soon.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Notification',
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
            count: _notifications.length,
          ),
          _FilterBar(selected: _filterIndex, onSelected: _selectFilter),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(17, 16, 17, 24),
              itemCount: _notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _NotificationCard(item: _notifications[index]),
            ),
          ),
        ],
      ),
    );
  }
}

const _filters = ['All', 'Unread', 'Rides'];

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.count});

  final VoidCallback onBack;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.ink,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notification',
                          style: TextStyle(
                            fontSize: 34,
                            height: 1,
                            letterSpacing: -2.04,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onDark,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Stay up to date with your rides.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.onDarkSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.profileVerifiedChipBg,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '$count new',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onDark,
                      ),
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

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            for (var i = 0; i < _filters.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onSelected(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected
                        ? AppColors.primary
                        : AppColors.inkSurfaceAlt,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _filters[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: i == selected
                          ? AppColors.notificationChipActiveText
                          : AppColors.onDarkChip,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationFeedItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0C0C0D),
            offset: Offset(0, 4),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Color(0x1A0C0C0D),
            offset: Offset(0, 16),
            blurRadius: 32,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 55,
            height: 53,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.unread
                  ? AppColors.primary
                  : AppColors.ink,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (item.unread)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(left: 8, top: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.notificationUnreadDot,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.historyStatLabel,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 16.5 / 10,
                    letterSpacing: 1.76,
                    fontWeight: FontWeight.w700,
                    color: AppColors.planLabel,
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
