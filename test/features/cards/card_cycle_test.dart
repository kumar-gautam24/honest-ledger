import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/features/cards/domain/entities/card_account.dart';
import 'package:recurring/features/cards/domain/entities/card_cycle.dart';
import 'package:recurring/features/cards/domain/entities/card_statement.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing_summary.dart';
import 'package:recurring/features/money_leak/domain/entities/repayment.dart';
import 'package:recurring/features/recurring/domain/entities/recurring_item.dart';

CardAccount card({
  String id = 'c1',
  String lenderId = 'l-icici',
  int statementDay = 15,
  int dueDay = 3,
  double? creditLimit,
}) {
  return CardAccount(
    id: id,
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
  String? cardId,
  required DateTime startDate,
  double principal = 12000,
  int months = 12,
}) {
  final b = Borrowing(
    id: 'b-$lenderId-${cardId ?? ''}-${startDate.month}',
    title: 'Card EMI',
    lenderId: lenderId,
    cardId: cardId,
    lenderName: 'ICICI Amazon Pay',
    principal: principal,
    startDate: startDate,
    createdAt: startDate,
    kind: BorrowingKind.fixedEmi,
    tenureMonths: months,
  );
  return BorrowingSummary.from(b, const <Repayment>[]);
}

RecurringItem subOnCard({
  String? cardId,
  required DateTime nextDueDate,
  double amount = 500,
  Frequency frequency = Frequency.monthly,
  bool isActive = true,
}) {
  return RecurringItem(
    id: 'r-${cardId ?? ''}-${nextDueDate.month}',
    title: 'Netflix',
    amount: amount,
    nextDueDate: nextDueDate,
    createdAt: DateTime(2026, 1, 1),
    frequency: frequency,
    cardId: cardId,
    isActive: isActive,
  );
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

  group('CardCycle.linksTo', () {
    test('explicit card link wins over lender', () {
      // Linked to c1 though its lender differs — still matches c1.
      expect(
        CardCycle.linksTo(card(), itemCardId: 'c1', itemLenderId: 'l-hdfc'),
        isTrue,
      );
      // Linked to another card — does not match c1 even on a lender match.
      expect(
        CardCycle.linksTo(card(), itemCardId: 'c2', itemLenderId: 'l-icici'),
        isFalse,
      );
    });

    test('falls back to lender when no card link', () {
      expect(CardCycle.linksTo(card(), itemLenderId: 'l-icici'), isTrue);
      expect(CardCycle.linksTo(card(), itemLenderId: 'l-hdfc'), isFalse);
    });

    test('no card link and no lender never matches', () {
      expect(CardCycle.linksTo(card()), isFalse);
    });
  });

  group('CardCycle.emiPortion', () {
    test('sums matching-lender installments inside the window (fallback)', () {
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

    test('explicit card link folds even when the lender differs', () {
      // Different lender, but explicitly billed on c1.
      final s = emiOnCard(
        lenderId: 'l-hdfc',
        cardId: 'c1',
        startDate: DateTime(2026, 6, 1),
      );
      final portion = CardCycle.emiPortion(
        card: card(),
        cycleMonth: DateTime(2026, 7),
        summaries: [s],
      );
      expect(portion, closeTo(1000, 0.001));
    });

    test('two same-lender cards: only the linked card folds the EMI', () {
      // Both cards are ICICI; the EMI is explicitly linked to c1.
      final s = emiOnCard(cardId: 'c1', startDate: DateTime(2026, 6, 1));
      final onC1 = CardCycle.emiPortion(
        card: card(id: 'c1'),
        cycleMonth: DateTime(2026, 7),
        summaries: [s],
      );
      final onC2 = CardCycle.emiPortion(
        card: card(id: 'c2'),
        cycleMonth: DateTime(2026, 7),
        summaries: [s],
      );
      expect(onC1, closeTo(1000, 0.001));
      expect(onC2, 0);
    });
  });

  group('CardCycle.recurringPortion', () {
    test('sums linked occurrences inside the window', () {
      // Netflix due 1 Jul, inside (15 Jun, 15 Jul], linked to c1.
      final r = subOnCard(cardId: 'c1', nextDueDate: DateTime(2026, 7, 1));
      final portion = CardCycle.recurringPortion(
        card: card(id: 'c1'),
        cycleMonth: DateTime(2026, 7),
        items: [r],
      );
      expect(portion, closeTo(500, 0.001));
    });

    test('unlinked or inactive item contributes nothing', () {
      final unlinked = subOnCard(nextDueDate: DateTime(2026, 7, 1));
      final inactive = subOnCard(
        cardId: 'c1',
        nextDueDate: DateTime(2026, 7, 1),
        isActive: false,
      );
      final portion = CardCycle.recurringPortion(
        card: card(id: 'c1'),
        cycleMonth: DateTime(2026, 7),
        items: [unlinked, inactive],
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
