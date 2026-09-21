import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/vehicle_listing.dart';
import '../providers/saved_vehicles_provider.dart';
import 'vehicle_color_picker.dart';

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
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
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
              children: [
                Expanded(
                  child: Text(
                    vehicle.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                _SaveButton(vehicle: vehicle),
                const SizedBox(width: 8),
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
                            ? 'Rent now'
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

/// Heart toggle in the sheet header, writing to the same
/// [SavedVehiclesProvider] the vehicle list and saved screen share — so a
/// save here shows up on the Saved tab straight away.
///
/// The list tile's heart sits on a dark tile and uses [AppColors.primary];
/// this one is on a white sheet, where lime reads badly, so it follows the
/// saved screen's light-surface treatment instead.
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.vehicle});

  final VehicleListing vehicle;

  @override
  Widget build(BuildContext context) {
    final saved = context.select<SavedVehiclesProvider, bool>(
      (p) => p.isSaved(vehicle.id),
    );

    return Semantics(
      button: true,
      label: saved
          ? 'Remove ${vehicle.name} from saved scooters'
          : 'Save ${vehicle.name}',
      child: GestureDetector(
        onTap: () => context.read<SavedVehiclesProvider>().toggle(vehicle.id),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            saved ? Icons.favorite : Icons.favorite_border,
            size: 24,
            color: saved ? AppColors.savedHeartFill : AppColors.inkSoft,
          ),
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
