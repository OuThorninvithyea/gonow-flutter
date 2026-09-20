import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/vehicle_listing.dart';

/// Row of color swatches for picking a vehicle's paint option.
///
/// Unavailable colors (Figma color-variant component marked out of stock)
/// are shown but disabled, with a small "Sold out" note beneath the row
/// when the selection lands on one — this only happens if the caller
/// deliberately selects an unavailable option, since [onSelected] does
/// not fire for disabled swatches.
class VehicleColorPicker extends StatelessWidget {
  const VehicleColorPicker({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  final List<VehicleColorOption> colors;
  final VehicleColorOption selected;
  final ValueChanged<VehicleColorOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              selected.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            if (!selected.available) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Sold out',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final color in colors) ...[
              _Swatch(
                option: color,
                selected: color.name == selected.name,
                onTap: color.available ? () => onSelected(color) : null,
              ),
              const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final VehicleColorOption option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Semantics(
      button: true,
      label: '${option.name}${disabled ? ', sold out' : ''}',
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: disabled ? 0.35 : 1,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.ink : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: option.swatch,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                      width: 0.5,
                    ),
                  ),
                ),
                if (disabled)
                  const Icon(Icons.close, size: 14, color: AppColors.onDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
