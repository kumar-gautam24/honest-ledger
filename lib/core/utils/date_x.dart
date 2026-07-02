import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

final _dayMonth = DateFormat('d MMM', AppConstants.locale);
final _dayMonthYear = DateFormat('d MMM yyyy', AppConstants.locale);
final _monthYear = DateFormat('MMMM yyyy', AppConstants.locale);
final _monthShort = DateFormat('MMM', AppConstants.locale);

extension DateFormatting on DateTime {
  /// `7 Jul`
  String get dayMonth => _dayMonth.format(this);

  /// `7 Jul 2026`
  String get dayMonthYear => _dayMonthYear.format(this);

  /// `July 2026`
  String get monthYear => _monthYear.format(this);

  /// `Jul`
  String get monthShort => _monthShort.format(this);

  DateTime get dateOnly => DateTime(year, month, day);

  /// Midnight on the first of this date's month.
  DateTime get monthStart => DateTime(year, month);

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  /// Add [months] (may be negative) keeping the day-of-month where possible
  /// (clamps month-end). Relies on DateTime normalising out-of-range months.
  DateTime addMonths(int months) {
    final anchor = DateTime(year, month + months);
    final lastDay = DateTime(anchor.year, anchor.month + 1, 0).day;
    return DateTime(anchor.year, anchor.month, day.clamp(1, lastDay));
  }

  /// Whole days from today (negative = overdue).
  int get daysFromNow {
    final today = DateTime.now().dateOnly;
    return dateOnly.difference(today).inDays;
  }
}

/// Human relative due label: "Today", "Tomorrow", "in 5 days", "3 days overdue".
String relativeDueLabel(DateTime date) {
  final d = date.daysFromNow;
  if (d == 0) return 'Today';
  if (d == 1) return 'Tomorrow';
  if (d == -1) return '1 day overdue';
  if (d < 0) return '${-d} days overdue';
  return 'in $d days';
}
