import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injector.dart';

part 'theme_controller.g.dart';

/// App theme mode, persisted in SharedPreferences. Defaults to dark — the app's
/// home turf.
@riverpod
class ThemeModeController extends _$ThemeModeController {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final stored = sl<SharedPreferences>().getString(_key);
    return ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.dark,
    );
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await sl<SharedPreferences>().setString(_key, mode.name);
  }
}
