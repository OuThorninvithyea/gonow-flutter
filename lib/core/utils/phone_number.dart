import 'package:flutter/services.dart';

String phoneDigits(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');
String formatPhoneDigits(String digits) {
  if (digits.length <= 3) return digits;
  if (digits.length <= 6) {
    return '${digits.substring(0, 3)} ${digits.substring(3)}';
  }
  return '${digits.substring(0, 3)} '
      '${digits.substring(3, 6)} '
      '${digits.substring(6)}';
}

String? validateCambodianPhone(String? value) {
  final digits = phoneDigits(value ?? '');
  if (digits.isEmpty) return 'Enter your phone number';
  if (!digits.startsWith('0')) return 'Phone must start with 0';
  if (digits.length < 9 || digits.length > CambodianPhoneFormatter.maxDigits) {
    return 'Enter a valid phone number';
  }
  return null;
}

class CambodianPhoneFormatter extends TextInputFormatter {
  const CambodianPhoneFormatter();

  static const int maxDigits = 10;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = phoneDigits(newValue.text);
    final capped = digits.length > maxDigits
        ? digits.substring(0, maxDigits)
        : digits;
    final formatted = formatPhoneDigits(capped);

    final caret = newValue.selection.end.clamp(0, newValue.text.length);
    final target = phoneDigits(newValue.text.substring(0, caret)).length;

    var offset = formatted.length;
    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (seen == target) {
        offset = i;
        break;
      }
      if (formatted[i] != ' ') seen++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
