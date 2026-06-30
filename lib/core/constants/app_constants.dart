/// App-wide constants. Financial defaults live here (editable in Settings),
/// never hardcoded at call sites.
abstract final class AppConstants {
  static const String appName = 'Recurring';

  /// Indian GST applied to interest and processing fees.
  static const double gstRate = 0.18;

  static const String currencySymbol = '₹';
  static const String locale = 'en_IN';

  /// Tenures (months) offered as quick chips in calculators.
  static const List<int> commonTenures = [3, 6, 9, 12, 18, 24, 36];

  /// Default reminder lead time before a due date.
  static const int defaultReminderLeadDays = 1;
}
