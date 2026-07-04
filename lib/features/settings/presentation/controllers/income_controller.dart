import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/auth_token_store.dart';
import '../../../../core/di/injector.dart';
import '../../data/settings_remote_source.dart';

part 'income_controller.g.dart';

/// Optional monthly income, persisted locally and (when signed in) synced to the
/// backend under the `income` setting. Null = not set; powers the
/// "left after obligations" line on Home and the %-of-income line on This Month.
@riverpod
class IncomeController extends _$IncomeController {
  static const prefsKey = 'monthly_income';

  @override
  double? build() {
    final value = sl<SharedPreferences>().getDouble(prefsKey);
    return (value == null || value <= 0) ? null : value;
  }

  Future<void> set(double? income) async {
    final prefs = sl<SharedPreferences>();
    if (income == null || income <= 0) {
      state = null;
      await prefs.remove(prefsKey);
      _push((remote) => remote.clearIncome());
    } else {
      state = income;
      await prefs.setDouble(prefsKey, income);
      _push((remote) => remote.pushIncome(income));
    }
  }

  /// Best-effort background sync to the backend; skipped when signed out or when
  /// the API is unreachable. Local prefs remain the source of truth for the UI.
  void _push(Future<void> Function(SettingsRemoteSource) op) {
    if (!sl<AuthTokenStore>().isSignedIn) return;
    unawaited(op(sl<SettingsRemoteSource>()).catchError((Object _) {}));
  }
}
