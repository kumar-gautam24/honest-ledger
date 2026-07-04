import 'package:flutter/animation.dart';

/// Motion tokens — durations and curves. Keep animation subtle and consistent.
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  /// The ledger "wasted" counter roll-up.
  static const Duration counter = Duration(milliseconds: 900);

  /// The branded launch moment: mark forms, motto appears, layer dissolves.
  static const Duration launch = Duration(milliseconds: 1500);

  /// Per-row stagger step for list reveals.
  static const Duration stagger = Duration(milliseconds: 40);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve exit = Curves.easeInCubic;
}
