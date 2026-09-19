import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/vehicle_listing.dart';
import '../../providers/saved_vehicles_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/vehicle_detail_sheet.dart';

/// Category filter chips above the vehicle list. "All" always matches;
/// the rest compare against [VehicleListing.category].
const _categories = ['All', 'e-scooter', 'electric', 'SUV'];

/// "Choose your ride" browse screen (Figma: "iPhone 16 Plus - 14"),
/// reached from the home screen's "View more".
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  int _categoryIndex = 1; // Figma defaults to "e-scooter" selected.

  List<VehicleListing> get _visible {
    final category = _categories[_categoryIndex];
    if (category == 'All') return vehicleListings;
    return vehicleListings.where((v) => v.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(
            selectedCategory: _categoryIndex,
            onCategorySelected: (i) => setState(() => _categoryIndex = i),
          ),
          _ResultsBar(count: visible.length),
          Expanded(
            child: SafeArea(
              top: false,
              child: visible.isEmpty
                  ? const Center(
                      child: Text(
                        'No vehicles in this category yet.',
                        style: TextStyle(color: AppColors.inkSoft),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                      itemCount: visible.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _VehicleTile(vehicle: visible[index]),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.map,
        onTap: (tab) {
          if (tab == AppNavTab.map) {
            context.push('/map');
            return;
          }
          if (tab == AppNavTab.home) {
            context.canPop() ? context.pop() : context.go('/home');
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
  const _Header({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final int selectedCategory;
  final ValueChanged<int> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, topInset + 8, 18, 24),
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.canPop() ? context.pop() : context.go('/home'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.inkBorder, width: 0.7),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.onDark,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'AVAILABLE NEARBY',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose your ride.',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.5,
              color: AppColors.onDark,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _todayLabel(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onDarkSubtle,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _categories.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _CategoryChip(
                    label: _categories[i],
                    selected: i == selectedCategory,
                    onTap: () => onCategorySelected(i),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _todayLabel() {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.inkSurfaceAlt,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.onPrimary : AppColors.onDarkChip,
          ),
        ),
      ),
    );
  }
}

class _ResultsBar extends StatelessWidget {
  const _ResultsBar({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Found $count vehicle${count == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 14, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 4),
              const Text(
                'Around downtown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          OutlinedButton(
            onPressed: () => context.push('/map'),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Map view',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({required this.vehicle});

  final VehicleListing vehicle;

  @override
  Widget build(BuildContext context) {
    final saved = context.select<SavedVehiclesProvider, bool>(
      (p) => p.isSaved(vehicle.id),
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 112,
            height: 128,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceTile,
              borderRadius: BorderRadius.circular(21),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: -32,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/home/scooter.png',
                  width: 112,
                  height: 112,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
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
                          Text(
                            vehicle.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.4,
                              color: AppColors.onDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vehicle.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                              color: AppColors.onDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.read<SavedVehiclesProvider>().toggle(
                        vehicle.id,
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          saved ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: saved ? AppColors.primary : AppColors.onDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.onDark,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${vehicle.distanceKm} km away',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.bolt,
                                size: 16,
                                color: AppColors.onDark,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${vehicle.batteryPercent}% charge',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showVehicleDetailSheet(context, vehicle),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
