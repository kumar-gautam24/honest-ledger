import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_motion.dart';
export 'app_spacing.dart';
export 'app_typography.dart';

/// Builds the app's [ThemeData] from the central token sets.
///
/// No screen should construct colors, text styles, paddings or radii directly —
/// they all flow from here and from the token classes in this folder.
abstract final class AppTheme {
  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);
  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData _build(Brightness brightness, AppColors c) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.background,
      primaryContainer: c.surfaceHigh,
      onPrimaryContainer: c.textHi,
      secondary: c.accent,
      onSecondary: c.background,
      tertiary: c.positive,
      onTertiary: c.background,
      error: c.cost,
      onError: brightness == Brightness.dark ? c.background : Colors.white,
      surface: c.surface,
      onSurface: c.textHi,
      surfaceContainerLowest: c.background,
      surfaceContainerHighest: c.surfaceHigh,
      outline: c.hairline,
      outlineVariant: c.hairline,
    );

    final textTheme = AppTypography.textTheme(c);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      textTheme: textTheme,
      extensions: [c],
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      dividerTheme: DividerThemeData(
        color: c.hairline,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        foregroundColor: c.textHi,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brCard),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.textLow),
        labelStyle: textTheme.bodyMedium?.copyWith(color: c.textMid),
        floatingLabelStyle: textTheme.labelLarge?.copyWith(color: c.accent),
        border: _inputBorder(c.hairline),
        enabledBorder: _inputBorder(c.hairline),
        focusedBorder: _inputBorder(c.accent, width: 1.5),
        errorBorder: _inputBorder(c.cost),
        focusedErrorBorder: _inputBorder(c.cost, width: 1.5),
        errorStyle: textTheme.bodySmall?.copyWith(color: c.cost),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.accent.withValues(alpha: 0.16),
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(letterSpacing: 0.3),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? c.accent : c.textLow,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.background,
          disabledBackgroundColor: c.surfaceHigh,
          disabledForegroundColor: c.textLow,
          // Height floor only. Size.fromHeight would force an infinite
          // minimum WIDTH, which crashes any button laid out where width is
          // unbounded (e.g. inside a Row). Full-width buttons come from
          // AppButton's `expand`, not from the theme.
          minimumSize: const Size(0, 52),
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brInput),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: textTheme.labelLarge,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: c.textHi),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brInput),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: AppRadius.brInput,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// Ergonomic theme access in widgets.
extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
