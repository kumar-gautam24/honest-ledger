import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Type system.
///
/// - Display / headlines / titles: **Space Grotesk** (characterful, mechanical).
/// - Body / labels: **Inter** (quiet, legible).
/// - Money & data: **JetBrains Mono** with tabular figures — every rupee
///   figure reads like a line on a printed statement.
abstract final class AppTypography {
  /// Tabular figures so digits never shift width as numbers animate.
  static const List<FontFeature> _tabular = [
    FontFeature.tabularFigures(),
    FontFeature.slashedZero(),
  ];

  static TextTheme textTheme(AppColors c) {
    final display = GoogleFonts.spaceGroteskTextTheme();
    final body = GoogleFonts.interTextTheme();

    final merged = body.copyWith(
      displayLarge: display.displayLarge,
      displayMedium: display.displayMedium,
      displaySmall: display.displaySmall,
      headlineLarge: display.headlineLarge,
      headlineMedium: display.headlineMedium,
      headlineSmall: display.headlineSmall,
      titleLarge: display.titleLarge,
    );

    return merged
        .apply(bodyColor: c.textHi, displayColor: c.textHi)
        .copyWith(
          titleMedium: merged.titleMedium?.copyWith(color: c.textHi),
          titleSmall: merged.titleSmall?.copyWith(color: c.textMid),
          bodyMedium: merged.bodyMedium?.copyWith(color: c.textMid, height: 1.45),
          bodySmall: merged.bodySmall?.copyWith(color: c.textMid, height: 1.4),
          labelLarge: merged.labelLarge?.copyWith(
            color: c.textHi,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          labelSmall: merged.labelSmall?.copyWith(
            color: c.textLow,
            letterSpacing: 0.8,
          ),
        );
  }

  /// An eyebrow / section label — small, spaced, low-emphasis caps.
  static TextStyle eyebrow(AppColors c) => GoogleFonts.jetBrainsMono(
        color: c.textLow,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.6,
      );

  // ---- Money styles (JetBrains Mono, tabular) ----

  /// Inline money figure inside rows and cards.
  static TextStyle money(AppColors c, {Color? color}) =>
      GoogleFonts.jetBrainsMono(
        color: color ?? c.textHi,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        fontFeatures: _tabular,
      );

  /// Emphasised money figure (totals, detail headers).
  static TextStyle moneyLarge(AppColors c, {Color? color}) =>
      GoogleFonts.jetBrainsMono(
        color: color ?? c.textHi,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.0,
        fontFeatures: _tabular,
      );

  /// The hero "wasted" / headline figure on dashboards.
  static TextStyle moneyHero(AppColors c, {Color? color}) =>
      GoogleFonts.jetBrainsMono(
        color: color ?? c.textHi,
        fontSize: 46,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: -1,
        fontFeatures: _tabular,
      );
}
