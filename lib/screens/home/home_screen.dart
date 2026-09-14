import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bottom_nav.dart';

/// Filter chips above the featured scooter.
const _filters = ['Nearby', 'Battery 80%+', 'Daily', 'Weekly'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _filterIndex = 0;

  void _notImplemented(String what) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$what is not built yet.')));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

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
                  onBellTap: () => _notImplemented('Notifications'),
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
                  onViewMore: () => _notImplemented('The scooter list'),
                ),
              ),
              const SizedBox(height: 52),
              Center(
                child: Image.asset(
                  'assets/images/home/scooter.png',
                  width: 210,
                  height: 210,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 74),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: _VehicleCard(
                  name: 'Fortuner GR',
                  range: '> 870km',
                  capacity: '50L',
                  price: r'$ 7.5/day',
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
          _notImplemented('The ${tab.name} tab');
        },
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

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home/promo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Scrim from the design — without it the white copy is unreadable
          // against the busy illustration.
          Positioned.fill(child: Container(color: const Color(0x63080707))),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 15, 24, 15),
            child: SizedBox(
              height: 112,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Promotions Today 20%',
                    style: TextStyle(
                      fontSize: 24,
                      height: 22 / 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.18,
                      color: AppColors.onDark,
                    ),
                  ),
                  SizedBox(height: 9),
                  Text(
                    'Book your Scooter now!!',
                    style: TextStyle(
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
