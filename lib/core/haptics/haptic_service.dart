import 'package:flutter/services.dart';

/// Central, semantic haptics. Widgets call intent ("success", "select")
/// rather than raw `HapticFeedback`, so feel stays consistent and can be
/// muted globally from Settings.
///
/// Registered as a singleton in the DI container.
class HapticService {
  HapticService({this.enabled = true});

  bool enabled;

  /// Light confirmation for taps on primary controls.
  Future<void> tap() async {
    if (enabled) await HapticFeedback.lightImpact();
  }

  /// Discrete tick when changing a selection (chips, tabs, steppers).
  Future<void> select() async {
    if (enabled) await HapticFeedback.selectionClick();
  }

  /// Saved / completed successfully.
  Future<void> success() async {
    if (enabled) await HapticFeedback.mediumImpact();
  }

  /// Destructive or attention-worthy action (delete, over-budget warning).
  Future<void> warning() async {
    if (enabled) await HapticFeedback.heavyImpact();
  }
}
