import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/features/cards/domain/entities/card_account.dart';
import 'package:recurring/features/cards/domain/entities/card_cycle.dart';
import 'package:recurring/features/cards/domain/entities/card_statement.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing_summary.dart';
import 'package:recurring/features/money_leak/domain/entities/repayment.dart';

CardAccount card({
  String lenderId = 'l-icici',
  int statementDay = 15,
  int dueDay = 3,
  double? creditLimit,
}) {
  return CardAccount(
    id: 'c1',
    lenderId: lenderId,
    name: 'ICICI Amazon Pay',
    statementDay: statementDay,
    dueDay: dueDay,
    creditLimit: creditLimit,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

BorrowingSummary emiOnCard({
  String lenderId = 'l-icici',
  required DateTime startDate,
  double principal = 12000,
  int months = 12,
}) {
  final b = Borrowing(
    id: 'b-$lenderId-${startDate.month}',
    title: 'Card EMI',
    lenderId: lenderId,
    lenderName: 'ICICI Amazon Pay',
    principal: principal,
    startDate: startDate,
    createdAt: startDate,
    kind: BorrowingKind.fixedEmi,
    tenureMonths: months,
  );
  return BorrowingSummary.from(b, const <Repayment>[]);
}

void main() {
  group('CardCycle.window', () {
    test('spend window is (prev statement, this statement]', () {
      final (start, end) = CardCycle.window(
        cycleMonth: DateTime(2026, 7),
        statementDay: 15,
      );
      expect(start, DateTime(2026, 6, 15));
      expect(end, DateTime(2026, 7, 15));
    });

    test('statement day 31 clamps to short months', () {
      final (start, end) = CardCycle.window(
        cycleMonth: DateTime(2026, 3),
        statementDay: 31,
      );
      expect(start, DateTime(2026, 2, 28)); // 2026 not a leap year
      expect(end, DateTime(2026, 3, 31));
    });
  });

  group('CardCycle.dueDateFor', () {
    test('due day after statement day lands the same month', () {
      expect(
        CardCycle.dueDateFor(
          cycleMonth: DateTime(2026, 7),
          statementDay: 15,
          dueDay: 25,
        ),
        DateTime(2026, 7, 25),
      );
    });

    test('due day before statement day rolls into the next month', () {
      expect(
        CardCycle.dueDateFor(
          cycleMonth: DateTime(2026, 7),
          statementDay: 15,
          dueDay: 3,
        ),
        DateTime(2026, 8, 3),
      );
    });
  });

  group('CardCycle.emiPortion', () {
    test('sums matching-lender installments inside the window', () {
      // EMI started 1 Jun → installment #1 due 1 Jul, inside (15 Jun, 15 Jul].
      final s = emiOnCard(startDate: DateTime(2026, 6, 1));
      final portion = CardCycle.emiPortion(
        card: card(),
        cycleMonth: DateTime(2026, 7),
        summaries: [s],
      );
      expect(portion, closeTo(1000, 0.001));
    });

    test('different lender or outside the window contributes nothing', () {
      final otherLender = emiOnCard(
        lenderId: 'l-hdfc',
        startDate: DateTime(2026, 6, 1),
      );
      // Started 1 Jul → #1 due 1 Aug, outside (15 Jun, 15 Jul].
      final outside = emiOnCard(startDate: DateTime(2026, 7, 1));
      final portion = CardCycle.emiPortion(
        card: card(),
        cycleMonth: DateTime(2026, 7),
        summaries: [otherLender, outside],
      );
      expect(portion, 0);
    });
  });

  test('otherSpends clamps at zero', () {
    expect(CardCycle.otherSpends(18400, 6200), closeTo(12200, 0.001));
    expect(CardCycle.otherSpends(5000, 6200), 0);
  });

  test('CardStatement.isPaid tolerates rounding', () {
    final s = CardStatement(
      id: 's1',
      cardId: 'c1',
      cycleMonth: DateTime(2026, 7),
      statementAmount: 18400,
      dueDate: DateTime(2026, 8, 3),
      paidAmount: 18400,
    );
    expect(s.isPaid, isTrue);
    expect(
      CardStatement(
        id: 's2',
        cardId: 'c1',
        cycleMonth: DateTime(2026, 7),
        statementAmount: 18400,
        dueDate: DateTime(2026, 8, 3),
        paidAmount: 18000,
      ).isPaid,
      isFalse,
    );
  });
}
