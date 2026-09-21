import 'package:flutter/material.dart';

/// Palette extracted from the GoNow Figma file ("Choose your ride" screen).
///
/// The design pairs a lime primary with a near-black ink. Lime is only ever
/// used behind [onPrimary] text — white on lime fails contrast badly.
class AppColors {
  AppColors._();

  /// Primary action colour. Always pair with [onPrimary] for text and icons.
  static const primary = Color(0xFFC7FF47);
  static const onPrimary = Color(0xFF292D32);

  /// Dark card / header fill, and the default heading colour on light.
  static const ink = Color(0xFF292D32);

  /// Inactive chip fill on a dark surface.
  static const inkSurfaceAlt = Color(0xFF3E4247);

  /// Hairline outline on a dark surface (e.g. the back button).
  static const inkBorder = Color(0xFF43464B);

  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);

  /// Tinted tile behind vehicle imagery.
  static const surfaceTile = Color(0xFFEEF0EA);

  /// Outline for secondary buttons on light.
  static const border = Color(0xFFD9DDD7);

  /// Hairline separator, e.g. the top edge of the bottom navigation bar.
  static const divider = Color(0xFFE4E8E3);

  /// Muted supporting text on a light surface.
  static const inkSoft = Color(0xFF8A9095);

  /// Onboarding uses a warmer grey-green text family than the ride screens.
  static const textBody = Color(0xFF69716C);
  static const textEyebrow = Color(0xFF77807A);
  static const textLink = Color(0xFF5D6660);

  /// Inactive page-indicator dot.
  static const dotInactive = Color(0xFFCFD5CD);

  /// Auth screens: pill field outline and placeholder text.
  static const fieldBorder = Color(0xFF8E8383);
  static const textPlaceholder = Color(0xFF555454);

  /// Hairline rule flanking the "or" separator.
  static const rule = Color(0xFF585858);

  static const onDark = Color(0xFFFFFFFF);

  /// Figma `alpha/dark/700` — 70% white, chip labels on dark.
  static const onDarkMuted = Color(0xB2FFFFFF);

  /// 65% white — the date line under the headline.
  static const onDarkSubtle = Color(0xA6FFFFFF);

  /// Label on the inactive dark chip.
  static const onDarkChip = Color(0xFFC5C6C8);

  /// Warm off-white page background behind the plan cards.
  static const canvas = Color(0xFFF7F8F4);

  /// Outline of an unselected plan card.
  static const planBorder = Color(0xFFE0E3DC);

  /// Outline of an unselected plan radio.
  static const planRadioBorder = Color(0xFFBEC4BC);

  /// Supporting copy inside a plan card.
  static const planSubtitle = Color(0xFF59605C);

  /// Small grey field labels ("Starts", "Return by").
  static const planLabel = Color(0xFF858C8A);

  /// Fill of the small "Change" chip.
  static const planChip = Color(0xFFF0F2ED);

  /// Dashed rule inside the schedule card.
  static const planDivider = Color(0xFFDCE0D9);

  /// Footnote under the schedule card.
  static const planFootnote = Color(0xFF777E79);

  /// Hairline divider inside receipt-style cards.
  static const receiptDivider = Color(0xFFEDF0EB);

  /// Muted price-breakdown row label/value on a white card.
  static const receiptMuted = Color(0xFF747C7A);

  /// Body copy inside the processing/success payment dialog.
  static const dialogBody = Color(0xFF6D756F);

  /// Track behind the payment-processing progress bar.
  static const progressTrack = Color(0xFFE0E4DD);

  /// Outline of the "Edit booking" pill on a receipt card.
  static const receiptCardBorder = Color(0xFFD8DDD6);

  /// Fill of the small battery/range chips on the booking-summary vehicle
  /// card. One hex step off [surfaceTile] in the Figma file, so kept as
  /// its own token rather than reusing that one.
  static const receiptChip = Color(0xFFEFF0EA);

  /// Location text on the booking-confirmed vehicle card.
  static const receiptLocation = Color(0xFF6F7772);

  /// Fill of the "I agree to the terms" pill.
  static const termsChipBg = Color(0xFFE9ECE5);

  /// Border of the unchecked terms checkbox.
  static const checkboxBorder = Color(0xFF767676);

  /// Checkmark glyph color on the lime "payment successful" badge.
  static const successCheckDark = Color(0xFF203026);

  /// Text on the lime "Available" badge over a vehicle card on the map.
  static const mapAvailableText = Color(0xFF395100);

  /// "Phnom Penh" location label in the map header, over the dark scrim.
  static const mapLocationLabel = Color(0xFFD8D8D8);

  /// "This month" / "Total spent" stat captions and each ride row's
  /// date · time · duration line.
  static const historyStatLabel = Color(0xFF79817C);

  /// "RECENT RENTALS" section eyebrow — one shade darker than
  /// [planLabel], which the summary card's month label uses instead.
  static const historySectionLabel = Color(0xFF7C847F);

  /// "Receipt" link on each ride row.
  static const historyReceiptLink = Color(0xFF587300);

  /// "Default" badge fill on the booking-receipt payment row, and the
  /// checkmark glyph on the pale-lime "payment received" badge. The glyph is
  /// one hex step off [successCheckDark] in the Figma file (different badge
  /// fill), so it stays its own token.
  static const profileDefaultBadgeBg = Color(0xFFE8F8BB);
  static const receiptCheckGreen = Color(0xFF476000);

  /// "N saved" count pill on the dark header.
  static const profileVerifiedChipBg = Color(0x1FFFFFFF);

  /// Inactive filter-chip label, and the supporting line under a saved
  /// vehicle's code.
  static const profileRowSubtextMuted = Color(0xFF89908B);

  /// Small "still available" dot beside a saved vehicle's code.
  static const notificationUnreadDot = Color(0xFF719700);

  /// Filled heart on a saved-vehicle card — tapping it unsaves the vehicle.
  static const savedHeartFill = Color(0xFFD94141);

  static const navActive = Color(0xFF415F00);
  static const navInactive = Color(0xFF7B837E);

  static const success = Color(0xFF17B26A);
  static const danger = Color(0xFFD92D20);
  static const warning = Color(0xFFF79009);
}
