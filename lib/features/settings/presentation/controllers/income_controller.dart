import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injector.dart';

part 'income_controller.g.dart';

/// Optional monthly income, persisted. Null = not set; powers the
/// "left after obligations" line on Home and the %-of-income line on
/// This Month — nothing else.
@riverpod
class IncomeController extends _$IncomeController {
  static const _key = 'monthly_income';

  @override
  double? build() {
    final value = sl<SharedPreferences>().getDouble(_key);
    return (value == null || value <= 0) ? null : value;
  }

  Future<void> set(double? income) async {
    final prefs = sl<SharedPreferences>();
    if (income == null || income <= 0) {
      state = null;
      await prefs.remove(_key);
    } else {
      state = income;
      await prefs.setDouble(_key, income);
    }
  }
}
