/// One monthly card bill: the single number the user enters, plus its
/// due/paid state. The EMI portion of the bill is derived, never stored.
class CardStatement {
  const CardStatement({
    required this.id,
    required this.cardId,
    required this.cycleMonth,
    required this.statementAmount,
    required this.dueDate,
    this.paidAmount = 0,
    this.paidDate,
    this.notes,
  });

  final String id;
  final String cardId;

  /// First day of the month this statement was generated in.
  final DateTime cycleMonth;
  final double statementAmount;
  final DateTime dueDate;
  final double paidAmount;
  final DateTime? paidDate;
  final String? notes;

  bool get isPaid => paidAmount + 0.005 >= statementAmount;

  double get remaining =>
      (statementAmount - paidAmount).clamp(0, double.infinity);

  CardStatement copyWith({
    double? statementAmount,
    DateTime? dueDate,
    double? paidAmount,
    DateTime? paidDate,
    String? notes,
  }) {
    return CardStatement(
      id: id,
      cardId: cardId,
      cycleMonth: cycleMonth,
      statementAmount: statementAmount ?? this.statementAmount,
      dueDate: dueDate ?? this.dueDate,
      paidAmount: paidAmount ?? this.paidAmount,
      paidDate: paidDate ?? this.paidDate,
      notes: notes ?? this.notes,
    );
  }
}
