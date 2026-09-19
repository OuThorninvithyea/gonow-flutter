import 'package:intl/intl.dart';

/// Figma shows relative day names near a booking date ("Today", "Tomorrow",
/// "Next Monday") and falls back to a date ("25 May") further out, so this
/// mirrors that instead of always printing a raw date.
///
/// Shared by the rental-plan, booking-summary and booking-confirmed screens
/// so "Starts" / "Return by" read identically across the whole flow.
String formatRentalDateTime(DateTime value) {
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  final days = DateTime(
    value.year,
    value.month,
    value.day,
  ).difference(startOfToday).inDays;

  final String day;
  if (days == 0) {
    day = 'Today';
  } else if (days == 1) {
    day = 'Tomorrow';
  } else if (days < 7) {
    day = DateFormat('EEEE').format(value);
  } else if (days < 14) {
    day = 'Next ${DateFormat('EEEE').format(value)}';
  } else {
    day = DateFormat('d MMM').format(value);
  }
  return '$day · ${DateFormat('h:mm a').format(value)}';
}
