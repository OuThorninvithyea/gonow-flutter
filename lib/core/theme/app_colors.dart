import 'package:flutter/material.dart';

/// Palette extracted from the GoNow Figma file ("Choose your ride" screen).
///
/// The design pairs a lime primary with a near-black ink. Lime is only ever
/// used behind [onPrimary] text — white on lime fails contrast badly.
class AppColors {
  AppColors._();

  // --- Brand ---------------------------------------------------------------

  /// Primary action colour. Always pair with [onPrimary] for text and icons.
  static const primary = Color(0xFFC7FF47);
  static const onPrimary = Color(0xFF292D32);

  // --- Dark surfaces -------------------------------------------------------

  /// Dark card / header fill, and the default heading colour on light.
  static const ink = Color(0xFF292D32);

  /// Inactive chip fill on a dark surface.
  static const inkSurfaceAlt = Color(0xFF3E4247);

  /// Hairline outline on a dark surface (e.g. the back button).
  static const inkBorder = Color(0xFF43464B);

  // --- Light surfaces ------------------------------------------------------

  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);

  /// Tinted tile behind vehicle imagery.
  static const surfaceTile = Color(0xFFEEF0EA);

  /// Outline for secondary buttons on light.
  static const border = Color(0xFFD9DDD7);

  /// Hairline separator, e.g. the top edge of the bottom navigation bar.
  static const divider = Color(0xFFE4E8E3);

  // --- Text ----------------------------------------------------------------

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

  // --- Rental plan screen (Figma "Choose your rental plan.") --------------

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

  // --- Navigation ----------------------------------------------------------

  static const navActive = Color(0xFF415F00);
  static const navInactive = Color(0xFF7B837E);

  // --- Status --------------------------------------------------------------

  static const success = Color(0xFF17B26A);
  static const danger = Color(0xFFD92D20);
  static const warning = Color(0xFFF79009);
}
