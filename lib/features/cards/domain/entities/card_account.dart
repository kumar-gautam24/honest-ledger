/// A credit card the user manages — statement-level only. References the
/// lender catalog ([lenderId]); card EMIs link automatically because
/// borrowings already carry the same lender id.
class CardAccount {
  const CardAccount({
    required this.id,
    required this.lenderId,
    required this.name,
    required this.statementDay,
    required this.dueDay,
    required this.createdAt,
    this.creditLimit,
    this.isActive = true,
  });

  final String id;
  final String lenderId;

  /// Display name resolved from the lender catalog.
  final String name;

  /// Day of month the statement is generated (1–31, clamped to month end).
  final int statementDay;

  /// Day of month the bill is due (1–31, clamped).
  final int dueDay;
  final double? creditLimit;
  final bool isActive;
  final DateTime createdAt;

  CardAccount copyWith({
    String? lenderId,
    String? name,
    int? statementDay,
    int? dueDay,
    double? creditLimit,
    bool clearCreditLimit = false,
    bool? isActive,
  }) {
    return CardAccount(
      id: id,
      lenderId: lenderId ?? this.lenderId,
      name: name ?? this.name,
      statementDay: statementDay ?? this.statementDay,
      dueDay: dueDay ?? this.dueDay,
      creditLimit: clearCreditLimit ? null : (creditLimit ?? this.creditLimit),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
