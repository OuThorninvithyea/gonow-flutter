import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'app_pill_field.dart';

/// The rounded CTA button used across auth screens (login, register, and
/// the forgot-password flow) — extracted once it showed up a third time.
///
/// Fills dark by default; once [isValid] flips true (the form is ready to
/// submit) it switches to the lime brand color, per [AppColors.primary]'s
/// contract of always pairing with [AppColors.onPrimary] text.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
    this.isValid = false,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isValid ? AppColors.primary : AppColors.ink;
    final foregroundColor = isValid ? AppColors.onPrimary : AppColors.onDark;

    return SizedBox(
      width: double.infinity,
      height: AppPillField.height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: AppColors.fieldBorder, width: 0.6),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        child: loading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Text(label),
      ),
    );
  }
}
