import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AppBackArrow extends StatelessWidget {
  const AppBackArrow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back, color: AppColors.ink, size: 24),
        ),
      ),
    );
  }
}
