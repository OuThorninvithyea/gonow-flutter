import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/vehicle_listing.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/vehicle_detail_sheet.dart';

/// Filter chips above the map — Figma frame `76:5410`.
const _filters = ['Nearby', 'Battery 80%+', 'Daily', 'Weekly'];

/// "Map" tab — Figma "iPhone 16 Plus - 13".
///
/// GoNow has no map SDK key yet (Google Maps / Mapsicle both need one), so
/// this renders the exported Mapsicle map as a static background image
/// instead of a real, pannable map. The header search box, filter chips
/// and nearby-scooter card are all live; only the map surface itself is a
/// picture. Swap [_MapBackground] for a real map widget once an API key
/// exists — everything else here should keep working unchanged.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.vehicle});

  /// The vehicle to focus on when arriving here to locate a specific
  /// scooter (e.g. "Start Navigation" from the booking-confirmed screen).
  /// Picks the matching filter chip so the nearby-scooter card shows this
  /// vehicle rather than whatever "Nearby" resolves to. Omit for the plain
  /// nav-tab entry point, which just shows the default filter.
  final VehicleListing? vehicle;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late int _filterIndex = _filterIndexFor(widget.vehicle);

  /// What the search box shows in place of its hint once the rider has
  /// picked somewhere via [_openPickupSearch] — null means "show the hint".
  late String? _searchedLocation = widget.vehicle?.location;

  /// [_filterIndex] resolves a filter tab to a vehicle; a search pick needs
  /// the inverse, so both the initial `widget.vehicle` and a freshly
  /// selected search result go through this one lookup.
  int _filterIndexFor(VehicleListing? vehicle) {
    if (vehicle == null) return 0;
    final index = _filters.indexOf(vehicle.filterTag);
    return index == -1 ? 0 : index;
  }

  VehicleListing get _nearestVehicle {
    final tag = _filters[_filterIndex];
    return vehicleListings.firstWhere(
      (v) => v.filterTag == tag,
      orElse: () => vehicleListings.first,
    );
  }

  /// Opens the search sheet and, if the rider picks a result, moves the map
  /// to that vehicle's filter/card. There's no geocoding API behind this —
  /// it matches against the same mock fleet everything else on this screen
  /// already uses, by name, area, and filter tag.
  Future<void> _openPickupSearch() async {
    final selected = await showModalBottomSheet<VehicleListing>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _PickupSearchSheet(),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _filterIndex = _filterIndexFor(selected);
      _searchedLocation = selected.location;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _nearestVehicle;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Map',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.onDark,
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _MapBackground()),
          Column(
            children: [
              // Reachable both as a nav tab (nothing to pop, go home) and
              // pushed on top of another screen (e.g. "Start Navigation"
              // from booking-confirmed) — pop back there when possible.
              _Header(
                onBack: () =>
                    context.canPop() ? context.pop() : context.go('/home'),
                onSearchTap: _openPickupSearch,
                searchLabel: _searchedLocation ?? 'Search pickup location',
                hasSearchValue: _searchedLocation != null,
              ),
              _FilterChips(
                selected: _filterIndex,
                onSelected: (i) => setState(() {
                  _filterIndex = i;
                  // A manual filter tap supersedes a prior search pick, so
                  // the search box shouldn't keep showing a stale location.
                  _searchedLocation = null;
                }),
              ),
              const Spacer(),
              _NearbyScooterCard(
                vehicle: vehicle,
                onViewScooter: () => showVehicleDetailSheet(context, vehicle),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.map,
        onTap: (tab) {
          if (tab == AppNavTab.map) return;
          if (tab == AppNavTab.home) {
            context.canPop() ? context.pop() : context.go('/home');
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

/// The static map image, per the class doc: swap this for a real map
/// widget once there's an API key. `BoxFit.cover` on a square Mapsicle
/// export means it crops rather than distorts on the app's tall aspect
/// ratio, which matches how Figma frames it.
class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/map/mapsicle_map.png', fit: BoxFit.cover);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onBack,
    required this.onSearchTap,
    required this.searchLabel,
    required this.hasSearchValue,
  });

  final VoidCallback onBack;
  final VoidCallback onSearchTap;
  final String searchLabel;
  final bool hasSearchValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.ink,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.mapLocationLabel,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Phnom Penh',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mapLocationLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Row(
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
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.inkBorder,
                            width: 0.7,
                          ),
                        ),
                        child: const Text(
                          '←',
                          style: TextStyle(
                            fontSize: 24,
                            color: AppColors.onDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'Search pickup location',
                      value: hasSearchValue ? searchLabel : null,
                      child: GestureDetector(
                        onTap: onSearchTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 43,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 20,
                                color: AppColors.ink,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  searchLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: hasSearchValue
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: hasSearchValue
                                        ? AppColors.ink
                                        : AppColors.inkSoft,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

/// Bottom sheet for "Search pickup location" — filters the same mock fleet
/// the rest of the map screen uses by scooter name, area, or filter tag.
/// Returns the picked [VehicleListing] via `Navigator.pop`, or null if the
/// rider dismisses it without choosing one.
class _PickupSearchSheet extends StatefulWidget {
  const _PickupSearchSheet();

  @override
  State<_PickupSearchSheet> createState() => _PickupSearchSheetState();
}

class _PickupSearchSheetState extends State<_PickupSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<VehicleListing> get _results {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return vehicleListings;
    return vehicleListings
        .where(
          (v) =>
              v.name.toLowerCase().contains(query) ||
              v.location.toLowerCase().contains(query) ||
              v.filterTag.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Padding(
      // Keeps the sheet above the keyboard instead of letting it cover
      // the text field.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                'Search pickup location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (value) => setState(() => _query = value),
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Search by scooter or area',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.inkSoft,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.inkSoft,
                  ),
                  filled: true,
                  fillColor: AppColors.canvas,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: results.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No pickup locations match "${_query.trim()}".',
                          style: const TextStyle(color: AppColors.inkSoft),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final result = results[index];
                          return _PickupResultTile(
                            vehicle: result,
                            onTap: () => Navigator.of(context).pop(result),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickupResultTile extends StatelessWidget {
  const _PickupResultTile({required this.vehicle, required this.onTap});

  final VehicleListing vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceTile,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.electric_scooter,
                  size: 20,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${vehicle.distanceKm} km',
                style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
              ),
            ],
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                  height: 32,
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
      ),
    );
  }
}

class _NearbyScooterCard extends StatelessWidget {
  const _NearbyScooterCard({
    required this.vehicle,
    required this.onViewScooter,
  });

  final VehicleListing vehicle;
  final VoidCallback onViewScooter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.1),
            offset: const Offset(0, -12),
            blurRadius: 14,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.dotInactive,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 108,
                  height: 101,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTile,
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Image.asset(
                    'assets/images/home/scooter.png',
                    width: 108,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
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
                                const Text(
                                  'NEARBY SCOOTER',
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1.5,
                                    letterSpacing: 1.65,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.planLabel,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vehicle.code,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    height: 28 / 20,
                                    letterSpacing: -0.8,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
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
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'Available',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.mapAvailableText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.receiptLocation,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(vehicle.distanceKm * 1000).round()} m away',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.receiptLocation,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.bolt,
                            size: 16,
                            color: AppColors.receiptLocation,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${vehicle.batteryPercent}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.receiptLocation,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            vehicle.range,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.receiptLocation,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'From ${vehicle.price}',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onViewScooter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: AppColors.onDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'View Scooter',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
