import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// INR formatting helpers. Single source of truth for how money is rendered.
abstract final class Money {
  static final NumberFormat _whole = NumberFormat.currency(
    locale: AppConstants.locale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  static final NumberFormat _precise = NumberFormat.currency(
    locale: AppConstants.locale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _compact = NumberFormat.compactCurrency(
    locale: AppConstants.locale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 1,
  );

  static final NumberFormat _grouped =
      NumberFormat.decimalPattern(AppConstants.locale);

  /// `₹15,240` — default for figures the user reads at a glance.
  static String format(num amount) => _whole.format(amount);

  /// `₹15,240.50` — for precise breakdowns (interest, EMI).
  static String precise(num amount) => _precise.format(amount);

  /// `₹10.5K` / `₹2.3L` — for tight spaces and chart labels.
  static String compact(num amount) => _compact.format(amount);

  /// Grouped digits without a symbol, for prefilling amount inputs
  /// (`75000` → `75,000`). Pairs with [IndianAmountInputFormatter].
  static String input(num amount) => _grouped.format(amount);

  /// `+₹5,240` / `-₹400` — signed delta for gains and leaks.
  static String signed(num amount) {
    final sign = amount > 0 ? '+' : amount < 0 ? '-' : '';
    return '$sign${format(amount.abs())}';
  }
}

/// Percentage formatting, e.g. `36%` or `18.96%`.
abstract final class Percent {
  static String format(num value, {int decimals = 2}) {
    final s = value.toStringAsFixed(decimals);
    final trimmed = s.contains('.')
        ? s.replaceFirst(RegExp(r'\.?0+$'), '')
        : s;
    return '$trimmed%';
  }
}
