import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme/app_colors.dart';

enum AppNavTab { home, map, rentals, saved, profile }

class _NavItem {
  const _NavItem(this.tab, this.label, this.asset, this.size);

  final AppNavTab tab;
  final String label;
  final String asset;

  /// Each icon has its own intrinsic size in the design.
  final Size size;
}

const _items = <_NavItem>[
  _NavItem(
    AppNavTab.home,
    'Home',
    'assets/icons/nav_home.svg',
    Size(19.5, 20.5),
  ),
  _NavItem(
    AppNavTab.map,
    'Map',
    'assets/icons/nav_map.svg',
    Size(21.5, 18.709),
  ),
  _NavItem(
    AppNavTab.rentals,
    'Rentals',
    'assets/icons/nav_rentals.svg',
    Size(24, 24),
  ),
  _NavItem(
    AppNavTab.saved,
    'Saved',
    'assets/icons/nav_saved.svg',
    Size(21, 18),
  ),
  _NavItem(
    AppNavTab.profile,
    'Profile',
    'assets/icons/nav_profile.svg',
    Size(17.997, 17.997),
  ),
];

/// Shared bottom navigation bar.
///
/// The Figma frame positions each item at a fixed x offset for a 431pt-wide
/// screen; this distributes them evenly instead so the bar holds up on other
/// widths.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.current, required this.onTap});

  final AppNavTab current;
  final ValueChanged<AppNavTab> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.702)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final item in _items)
                _NavButton(
                  item: item,
                  active: item.tab == current,
                  onTap: () => onTap(item.tab),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.navActive : AppColors.navInactive;

    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 60,
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                item.asset,
                width: item.size.width,
                height: item.size.height,
                // The exported icons are flat black (profile is a grey
                // stroke), so state has to come from a tint.
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  height: 16.5 / 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
