import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

final _dayMonth = DateFormat('d MMM', AppConstants.locale);
final _dayMonthYear = DateFormat('d MMM yyyy', AppConstants.locale);

extension DateFormatting on DateTime {
  /// `7 Jul`
  String get dayMonth => _dayMonth.format(this);

  /// `7 Jul 2026`
  String get dayMonthYear => _dayMonthYear.format(this);

  DateTime get dateOnly => DateTime(year, month, day);

  /// Add [months] keeping the day-of-month where possible (clamps month-end).
  DateTime addMonths(int months) {
    final totalMonth = month - 1 + months;
    final newYear = year + (totalMonth ~/ 12);
    final newMonth = totalMonth % 12 + 1;
    final lastDay = DateTime(newYear, newMonth + 1, 0).day;
    return DateTime(newYear, newMonth, day.clamp(1, lastDay));
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
