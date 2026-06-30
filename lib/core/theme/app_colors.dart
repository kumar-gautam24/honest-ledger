import 'package:flutter/material.dart';

/// Raw palette — the only place hex literals are allowed to live.
/// Everything else consumes [AppColors] semantic tokens via the theme.
abstract final class _Palette {
  // Dark — "ink" base, a private bank-statement at night.
  static const inkDark = Color(0xFF0E1116);
  static const surfaceDark = Color(0xFF161B22);
  static const surfaceHighDark = Color(0xFF1F2630);
  static const hairlineDark = Color(0xFF2A323D);
  static const textHiDark = Color(0xFFECEEF1);
  static const textMidDark = Color(0xFF9BA3AE);
  static const textLowDark = Color(0xFF5C6470);

  // Light — warm paper statement.
  static const paperLight = Color(0xFFF7F6F2);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceHighLight = Color(0xFFF1EFE9);
  static const hairlineLight = Color(0xFFE2DFD6);
  static const textHiLight = Color(0xFF15181C);
  static const textMidLight = Color(0xFF5A6068);
  static const textLowLight = Color(0xFF8A8F98);

  // Brand accents.
  static const brass = Color(0xFFC9A227); // restrained, expensive accent
  static const brassLight = Color(0xFF9A7B12); // accessible on paper
  static const ember = Color(0xFFE0533D); // cost / wasted / money leaking out
  static const emberLight = Color(0xFFC23B27);
  static const mint = Color(0xFF4ADE9A); // paid off / saved — used rarely
  static const mintLight = Color(0xFF1E9E6A);
}

/// Semantic color tokens for the app, resolved per brightness.
///
/// Read in widgets via `Theme.of(context).extension<AppColors>()!` or the
/// `context.colors` getter in `app_theme.dart`. Never reference [_Palette].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.hairline,
    required this.accent,
    required this.cost,
    required this.positive,
    required this.textHi,
    required this.textMid,
    required this.textLow,
  });

  /// App scaffold background.
  final Color background;

  /// Default card / sheet surface.
  final Color surface;

  /// Raised surface (selected, nested cards, input fills).
  final Color surfaceHigh;

  /// 1px rules and dividers — statement-line feel.
  final Color hairline;

  /// Brass accent — highlights, the signature underline, primary actions.
  final Color accent;

  /// Cost / interest / "wasted" figures. The emotional red.
  final Color cost;

  /// Money saved / loan paid off. Used sparingly.
  final Color positive;

  final Color textHi;
  final Color textMid;
  final Color textLow;

  static const dark = AppColors(
    background: _Palette.inkDark,
    surface: _Palette.surfaceDark,
    surfaceHigh: _Palette.surfaceHighDark,
    hairline: _Palette.hairlineDark,
    accent: _Palette.brass,
    cost: _Palette.ember,
    positive: _Palette.mint,
    textHi: _Palette.textHiDark,
    textMid: _Palette.textMidDark,
    textLow: _Palette.textLowDark,
  );

  static const light = AppColors(
    background: _Palette.paperLight,
    surface: _Palette.surfaceLight,
    surfaceHigh: _Palette.surfaceHighLight,
    hairline: _Palette.hairlineLight,
    accent: _Palette.brassLight,
    cost: _Palette.emberLight,
    positive: _Palette.mintLight,
    textHi: _Palette.textHiLight,
    textMid: _Palette.textMidLight,
    textLow: _Palette.textLowLight,
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? hairline,
    Color? accent,
    Color? cost,
    Color? positive,
    Color? textHi,
    Color? textMid,
    Color? textLow,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      hairline: hairline ?? this.hairline,
      accent: accent ?? this.accent,
      cost: cost ?? this.cost,
      positive: positive ?? this.positive,
      textHi: textHi ?? this.textHi,
      textMid: textMid ?? this.textMid,
      textLow: textLow ?? this.textLow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      cost: Color.lerp(cost, other.cost, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      textHi: Color.lerp(textHi, other.textHi, t)!,
      textMid: Color.lerp(textMid, other.textMid, t)!,
      textLow: Color.lerp(textLow, other.textLow, t)!,
    );
  }
}
