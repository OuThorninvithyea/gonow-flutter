import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';

class AppPillField extends StatelessWidget {
  const AppPillField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.suffixIcon,
  });

  static const double height = 58.289;

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextAlign textAlign;

  /// Optional trailing widget, e.g. the show/hide-password toggle.
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
      borderSide: BorderSide(color: AppColors.fieldBorder, width: 0.6),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      textAlign: textAlign,
      style: const TextStyle(fontSize: 16, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPlaceholder,
        ),
        filled: false,
        suffixIcon: suffixIcon,
        counterText: maxLength != null ? '' : null,
        // Vertical padding is what produces the 58.29pt height alongside the
        // 16pt text; a fixed SizedBox would clip the validation message.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 18,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: AppColors.ink, width: 1.2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: AppColors.danger, width: 0.6),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: AppColors.danger, width: 1.2),
        ),
      ),
    );
  }
}
