import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/vehicle_listing.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/vehicle_detail_sheet.dart';

/// Filter chips above the featured scooter, in display order.
const _filters = ['Nearby', 'Battery 80%+', 'Daily', 'Weekly'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _filterIndex = 0;

  VehicleListing get _featuredVehicle {
    final tag = _filters[_filterIndex];
    return vehicleListings.firstWhere(
      (v) => v.filterTag == tag,
      orElse: () => vehicleListings.first,
    );
  }

  void _comingSoon(String what) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$what is coming soon.')));
  }

  void _showNotifications() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final vehicle = _featuredVehicle;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: _Header(
                  name: user?.fullName ?? 'Rider',
                  onBellTap: _showNotifications,
                ),
              ),
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: _PromoBanner(),
              ),
              const SizedBox(height: 29),
              _FilterChips(
                selected: _filterIndex,
                onSelected: (i) => setState(() => _filterIndex = i),
              ),
              const SizedBox(height: 37),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: _SectionHeader(
                  onViewMore: () => context.push('/vehicles'),
                ),
              ),
              const SizedBox(height: 52),
              Center(
                child: GestureDetector(
                  onTap: () => showVehicleDetailSheet(context, vehicle),
                  child: Image.asset(
                    'assets/images/home/scooter.png',
                    width: 210,
                    height: 210,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 74),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: GestureDetector(
                  onTap: () => showVehicleDetailSheet(context, vehicle),
                  child: _VehicleCard(
                    name: vehicle.name,
                    range: vehicle.range,
                    capacity: vehicle.capacity,
                    price: vehicle.price,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.home,
        onTap: (tab) {
          if (tab == AppNavTab.home) return;
          if (tab == AppNavTab.map) {
            context.push('/map');
            return;
          }
          _comingSoon('The ${tab.name} tab');
        },
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  static const _notifications = [
    ('Booking confirmed', 'Your Fortuner GR is reserved for today.'),
    ('Promotion', '20% off all scooters this week only.'),
    ('Battery alert', 'Nearby scooters are fully charged and ready.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 12, 25, 25),
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
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            for (final n in _notifications) ...[
              Text(
                n.$1,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                n.$2,
                style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.onBellTap});

  final String name;
  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    // Figma's avatar is a Code Connect primitive with a placeholder image, so
    // no asset was exported. Fall back to a single initial, per the component
    // description in the design file.
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.ink,
                shape: BoxShape.circle,
              ),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const Text(
                  'Standard member',
                  style: TextStyle(fontSize: 14, color: AppColors.inkSoft),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          key: const Key('home_bell_button'),
          onTap: onBellTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/bell.svg',
                width: 23,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.ink,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One slide of the rotating promo carousel.
class _Promo {
  const _Promo({
    required this.asset,
    required this.headline,
    required this.subtitle,
  });

  final String asset;
  final String headline;
  final String subtitle;
}

const _promos = [
  _Promo(
    asset: 'assets/images/home/promo.jpg',
    headline: 'Promotions Today 20%',
    subtitle: 'Book your Scooter now!!',
  ),
  _Promo(
    asset: 'assets/images/home/promo2.jpg',
    headline: 'Weekend Special',
    subtitle: 'Ride free on your first hour',
  ),
  _Promo(
    asset: 'assets/images/home/promo3.jpg',
    headline: 'New Fleet Arrived',
    subtitle: 'Try the latest e-scooters today',
  ),
  _Promo(
    asset: 'assets/images/home/promo4.jpg',
    headline: 'Refer & Earn',
    subtitle: 'Invite a friend, get \$5 credit',
  ),
];

/// Auto-rotating promo banner. Cycles through [_promos] every 3 seconds
/// with a crossfade, and shows a dot indicator for the current slide.
class _PromoBanner extends StatefulWidget {
  const _PromoBanner();

  @override
  State<_PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<_PromoBanner> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _promos.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promo = _promos[_index];

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Image.asset(
                promo.asset,
                key: ValueKey(promo.asset),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          // Scrim from the design — without it the white copy is unreadable
          // against the busy illustration.
          Positioned.fill(child: Container(color: const Color(0x63080707))),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 15, 24, 15),
            child: SizedBox(
              height: 112,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey(promo.headline),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promo.headline,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 22 / 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.18,
                            color: AppColors.onDark,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          promo.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 22 / 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.18,
                            color: AppColors.onDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < _promos.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: i == _index ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? AppColors.primary
                                : AppColors.onDarkMuted,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ],
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

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          for (var i = 0; i < _filters.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onSelected(i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 31.973,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == selected
                      ? AppColors.primary
                      : AppColors.inkSurfaceAlt,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      offset: Offset(0, 1),
                      blurRadius: 1.5,
                    ),
                  ],
                ),
                child: Text(
                  _filters[i],
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: i == selected
                        ? AppColors.onPrimary
                        : AppColors.onDarkChip,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.onViewMore});

  final VoidCallback onViewMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 27,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'e-sctooer',
            style: TextStyle(
              fontSize: 16,
              height: 22 / 16,
              letterSpacing: -0.18,
              color: AppColors.ink,
            ),
          ),
        ),
        GestureDetector(
          onTap: onViewMore,
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'View more',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.name,
    required this.range,
    required this.capacity,
    required this.price,
  });

  final String name;
  final String range;
  final String capacity;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 63,
      padding: const EdgeInsets.symmetric(horizontal: 21),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0C0C0D),
            offset: Offset(0, 16),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  height: 22 / 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.18,
                  color: AppColors.onDark,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/gps.svg',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(range, style: _spec),
                  const SizedBox(width: 16),
                  SvgPicture.asset(
                    'assets/icons/fuel.svg',
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(capacity, style: _spec),
                ],
              ),
            ],
          ),
          Container(
            height: 29,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                height: 22 / 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.18,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _spec = TextStyle(
    fontSize: 12,
    height: 1.2,
    color: AppColors.onDark,
  );
}
