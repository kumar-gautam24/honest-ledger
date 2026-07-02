import '../../../../core/utils/date_x.dart';

/// What kind of recurring obligation this is.
enum RecurringType {
  subscription('Subscription'),
  bill('Bill'),
  emi('EMI');

  const RecurringType(this.label);
  final String label;
}

/// How often it recurs. [perYear] drives normalisation to a monthly figure.
enum Frequency {
  weekly('Weekly', 52),
  monthly('Monthly', 12),
  quarterly('Quarterly', 4),
  yearly('Yearly', 1);

  const Frequency(this.label, this.perYear);
  final String label;
  final int perYear;

  /// [from] stepped one occurrence forward.
  DateTime advance(DateTime from) => switch (this) {
        Frequency.weekly => from.add(const Duration(days: 7)),
        Frequency.monthly => from.addMonths(1),
        Frequency.quarterly => from.addMonths(3),
        Frequency.yearly => from.addMonths(12),
      };

  /// [from] stepped one occurrence back.
  DateTime retreat(DateTime from) => switch (this) {
        Frequency.weekly => from.subtract(const Duration(days: 7)),
        Frequency.monthly => from.addMonths(-1),
        Frequency.quarterly => from.addMonths(-3),
        Frequency.yearly => from.addMonths(-12),
      };
}

/// A subscription, bill, or EMI that repeats on a schedule.
class RecurringItem {
  const RecurringItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.nextDueDate,
    required this.createdAt,
    this.type = RecurringType.subscription,
    this.frequency = Frequency.monthly,
    this.category,
    this.isActive = true,
    this.notes,
  });

  final String id;
  final String title;
  final RecurringType type;
  final double amount;
  final Frequency frequency;
  final DateTime nextDueDate;
  final String? category;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;

  /// Amount normalised to a per-month figure, for outflow totals.
  double get monthlyAmount => amount * frequency.perYear / 12;

  /// The next due date after this one, rolled forward by the frequency.
  DateTime advanceDue() => frequency.advance(nextDueDate);

  RecurringItem copyWith({
    String? title,
    RecurringType? type,
    double? amount,
    Frequency? frequency,
    DateTime? nextDueDate,
    String? category,
    bool? isActive,
    String? notes,
  }) {
    return RecurringItem(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
