import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../models/vehicle_listing.dart';
import 'vehicle_color_picker.dart';

/// Bottom sheet showing full vehicle detail with a working "Rent now" CTA.
///
/// Used from the home screen (tapping the featured scooter image or the
/// dark vehicle card) and from the full vehicle list.
Future<void> showVehicleDetailSheet(
  BuildContext context,
  VehicleListing vehicle,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _VehicleDetailSheet(vehicle: vehicle),
  );
}

class _VehicleDetailSheet extends StatefulWidget {
  const _VehicleDetailSheet({required this.vehicle});

  final VehicleListing vehicle;

  @override
  State<_VehicleDetailSheet> createState() => _VehicleDetailSheetState();
}

class _VehicleDetailSheetState extends State<_VehicleDetailSheet> {
  bool _booking = false;
  late VehicleColorOption _selectedColor;

  @override
  void initState() {
    super.initState();
    // Default to the first available color rather than always colors[0], so
    // a vehicle whose default paint is sold out doesn't open on a disabled
    // option with nothing pre-selected.
    _selectedColor = widget.vehicle.colors.firstWhere(
      (c) => c.available,
      orElse: () => widget.vehicle.colors.first,
    );
  }

  Future<void> _rentNow() async {
    if (!_selectedColor.available) return;
    setState(() => _booking = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    // Grab the router before popping: the sheet's context is defunct once
    // it's gone, so it can't be used to push the next route.
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    // Renting now picks a plan rather than booking outright — Figma
    // "Choose your rental plan." is the next step in the flow.
    await router.push<void>('/rental-plan', extra: widget.vehicle);
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;

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
            Center(
              child: Image.asset(
                _selectedColor.asset,
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vehicle.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    vehicle.price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              vehicle.description,
              style: const TextStyle(fontSize: 14, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Spec(icon: Icons.gps_fixed, label: vehicle.range),
                const SizedBox(width: 20),
                _Spec(icon: Icons.local_gas_station, label: vehicle.capacity),
              ],
            ),
            if (vehicle.colors.isNotEmpty) ...[
              const SizedBox(height: 20),
              VehicleColorPicker(
                colors: vehicle.colors,
                selected: _selectedColor,
                onSelected: (c) => setState(() => _selectedColor = c),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_booking || !_selectedColor.available)
                    ? null
                    : _rentNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: _selectedColor.available
                      ? AppColors.primary
                      : AppColors.border,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _booking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(
                        _selectedColor.available
                            ? 'Choose rental plan'
                            : '${_selectedColor.name} sold out',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.inkSoft),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
        ),
      ],
    );
  }
}
