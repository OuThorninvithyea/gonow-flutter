import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/tab_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../models/vehicle_listing.dart';
import '../../providers/saved_vehicles_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/vehicle_detail_sheet.dart';

const _filters = ['All', 'Nearby', 'Available'];

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int _filterIndex = 0;

  void _selectFilter(int index) {
    if (index == 0) {
      setState(() => _filterIndex = index);
      return;
    }
    setState(() => _filterIndex = index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_filters[index]} filtering is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedIds = context.watch<SavedVehiclesProvider>().savedIds;
    final savedVehicles = vehicleListings
        .where((v) => savedIds.contains(v.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          _Header(count: savedVehicles.length),
          _FilterBar(selected: _filterIndex, onSelected: _selectFilter),
          Expanded(
            child: savedVehicles.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: savedVehicles.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '${savedVehicles.length} '
                            '${savedVehicles.length == 1 ? 'scooter' : 'scooters'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.76,
                              color: AppColors.historySectionLabel,
                            ),
                          ),
                        );
                      }
                      return _SavedVehicleCard(
                        vehicle: savedVehicles[index - 1],
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.saved,
        onTap: (tab) => goToTab(context, tab, from: AppNavTab.saved),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved scooters',
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
                          'Your shortlist, ready to compare.',
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
                      '$count saved',
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
      color: AppColors.canvas,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < _filters.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onSelected(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.ink : AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _filters[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: i == selected
                              ? AppColors.onDark
                              : AppColors.profileRowSubtextMuted,
                        ),
                      ),
                      if (_filters[i] == 'Available') ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
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

class _SavedVehicleCard extends StatelessWidget {
  const _SavedVehicleCard({required this.vehicle});

  final VehicleListing vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D232D26),
            offset: Offset(0, 6),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => showVehicleDetailSheet(context, vehicle),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 66,
              height: 66,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Image.asset(
                'assets/images/home/scooter.png',
                width: 38,
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => showVehicleDetailSheet(context, vehicle),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        vehicle.code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.notificationUnreadDot,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.location} · ${(vehicle.distanceKm * 1000).round()} m away',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.dialogBody,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Available now',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.historyReceiptLink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Remove ${vehicle.code} from saved scooters',
            child: GestureDetector(
              onTap: () =>
                  context.read<SavedVehiclesProvider>().toggle(vehicle.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.favorite,
                  size: 20,
                  color: AppColors.savedHeartFill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 40,
              color: AppColors.inkSoft,
            ),
            const SizedBox(height: 12),
            const Text(
              'No saved scooters yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap the heart on any scooter to shortlist it here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => context.push('/vehicles'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Browse scooters',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
