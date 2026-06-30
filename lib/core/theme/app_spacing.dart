import 'package:flutter/widgets.dart';

/// Spacing scale (4-point grid). Use these instead of raw numbers.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Default screen edge padding.
  static const EdgeInsets screen = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: lg,
  );

  // Common gap widgets to keep layout code terse and consistent.
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);

  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: md);
  static const SizedBox hGapLg = SizedBox(width: lg);

  static const SizedBox vGapSm = SizedBox(height: sm);
  static const SizedBox vGapMd = SizedBox(height: md);
  static const SizedBox vGapLg = SizedBox(height: lg);
  static const SizedBox vGapXl = SizedBox(height: xl);
}

/// Corner radius scale.
abstract final class AppRadius {
  static const double sm = 8;
  static const double input = 12;
  static const double card = 16;
  static const double sheet = 24;
  static const double pill = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brInput = BorderRadius.all(Radius.circular(input));
  static const BorderRadius brCard = BorderRadius.all(Radius.circular(card));
  static const BorderRadius brSheet = BorderRadius.all(Radius.circular(sheet));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));
}
