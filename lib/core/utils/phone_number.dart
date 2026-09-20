import 'package:flutter/services.dart';

/// Strips everything but digits — use this before sending a phone number
/// anywhere, since the field displays it grouped as `0XX XXX XXX`.
String phoneDigits(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');

/// Groups Cambodian mobile digits the way they are written locally:
/// `012 345 678` for 9 digits, `012 345 6789` for the 10-digit ranges.
String formatPhoneDigits(String digits) {
  if (digits.length <= 3) return digits;
  if (digits.length <= 6) {
    return '${digits.substring(0, 3)} ${digits.substring(3)}';
  }
  return '${digits.substring(0, 3)} '
      '${digits.substring(3, 6)} '
      '${digits.substring(6)}';
}

/// Validates a Cambodian mobile number: leading 0, then 9–10 digits total.
/// Returns null when valid, otherwise the message to show under the field.
String? validateCambodianPhone(String? value) {
  final digits = phoneDigits(value ?? '');
  if (digits.isEmpty) return 'Enter your phone number';
  if (!digits.startsWith('0')) return 'Phone must start with 0';
  if (digits.length < 9 || digits.length > CambodianPhoneFormatter.maxDigits) {
    return 'Enter a valid phone number';
  }
  return null;
}

/// Keeps a phone field digits-only and live-formats it as `0XX XXX XXX`.
///
/// Letters and symbols never make it into the field at all, so the validator
/// only has to care about length and the leading zero.
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

    // Count the digits ahead of the caret and re-find that position in the
    // grouped string, so typing mid-number doesn't fling the caret around.
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
