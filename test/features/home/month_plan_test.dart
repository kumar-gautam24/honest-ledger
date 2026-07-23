import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/features/cards/domain/entities/card_account.dart';
import 'package:recurring/features/cards/domain/entities/card_statement.dart';
import 'package:recurring/features/home/domain/entities/month_plan.dart';
import 'package:recurring/features/home/domain/entities/obligation_category.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/money_leak/domain/entities/repayment.dart';
import 'package:recurring/features/recurring/domain/entities/recurring_item.dart';

import 'fixtures.dart';

void main() {
  // Mid-July 2026; the plan month is July.
  final now = DateTime(2026, 7, 15);

  group('MonthPlan — fixed EMIs', () {
    test('the installment due this month is a due; earlier unpaid ones are carry-over', () {
      // Started 1 Mar → installments due 1 Apr..1 Mar next year; #4 due 1 Jul.
      final s = emiSummary(startDate: DateTime(2026, 3, 1));
      final plan = MonthPlan.from(summaries: [s], items: const [], now: now);

      expect(plan.month, DateTime(2026, 7));
      expect(plan.dues, hasLength(1));
      final due = plan.dues.single;
      expect(due.source, MonthDueSource.emiInstallment);
      expect(due.dueDate, DateTime(2026, 7, 1));
      expect(due.amountDue, closeTo(1000, 0.001));
      expect(due.amountPaid, 0);
      expect(due.isOverdue(now), isTrue);
      // #1–#3 (Apr–Jun) unpaid → carried over, not part of this month's due.
      expect(plan.carriedOver, closeTo(3000, 0.001));
      expect(plan.totalDue, closeTo(1000, 0.001));
    });

    test('a paid installment counts toward paid-so-far', () {
      final s = emiSummary(startDate: DateTime(2026, 3, 1), paidInstallments: 4);
      final plan = MonthPlan.from(summaries: [s], items: const [], now: now);
      final due = plan.dues.single;
      expect(due.isPaid, isTrue);
      expect(plan.totalPaid, closeTo(1000, 0.001));
      expect(plan.remaining, 0);
      expect(plan.carriedOver, 0);
    });

    test('a closed EMI keeps its paid installment this month but drops unpaid rows', () {
      // Paid #4 (due 1 Jul) then foreclosed.
      final s = emiSummary(
        startDate: DateTime(2026, 3, 1),
        paidInstallments: 4,
        status: BorrowingStatus.closed,
      );
      final plan = MonthPlan.from(summaries: [s], items: const [], now: now);
      expect(plan.dues, hasLength(1));
      expect(plan.dues.single.isPaid, isTrue);
      expect(plan.carriedOver, 0);
    });

    test('a closed EMI with nothing paid this month contributes nothing', () {
      final s = emiSummary(
        startDate: DateTime(2026, 3, 1),
        status: BorrowingStatus.closed,
      );
      final plan = MonthPlan.from(summaries: [s], items: const [], now: now);
      expect(plan.dues, isEmpty);
      expect(plan.carriedOver, 0);
    });
  });

  group('MonthPlan — flexible loans', () {
    test('one undated due at the planned payment with ledger progress', () {
      final s = loanSummary(
        startDate: DateTime(2026, 6, 1),
        minPayment: 5000,
        repayments: [
          Repayment(
            id: 'r1',
            borrowingId: 'loan-1',
            amount: 2000,
            date: DateTime(2026, 7, 5),
          ),
          Repayment(
            id: 'r2',
            borrowingId: 'loan-1',
            amount: 1000,
            date: DateTime(2026, 7, 12),
          ),
          // June payment must not count toward July.
          Repayment(
            id: 'r0',
            borrowingId: 'loan-1',
            amount: 500,
            date: DateTime(2026, 6, 20),
          ),
        ],
      );
      final plan = MonthPlan.from(summaries: [s], items: const [], now: now);
      final due = plan.dues.single;
      expect(due.source, MonthDueSource.flexiblePlan);
      expect(due.dueDate, isNull);
      expect(due.amountDue, 5000);
      expect(due.amountPaid, 3000);
      expect(due.remaining, 2000);
      expect(due.isPaid, isFalse);
    });

    test('overpayment shows on the row but plan totals cap at the planned amount', () {
      final s = loanSummary(
        startDate: DateTime(2026, 6, 1),
        minPayment: 5000,
        repayments: [
          Repayment(
            id: 'r1',
            borrowingId: 'loan-1',
            amount: 6000,
            date: DateTime(2026, 7, 3),
          ),
        ],
      );
      final plan = MonthPlan.from(summaries: [s], items: const [], now: now);
      expect(plan.dues.single.amountPaid, 6000);
      expect(plan.totalPaid, 5000);
      expect(plan.remaining, 0);
      expect(plan.dues.single.isPaid, isTrue);
    });

    test('a loan without a planned payment is a noPlan row excluded from totals', () {
      final s = loanSummary(startDate: DateTime(2026, 6, 1), minPayment: 0);
      final plan = MonthPlan.from(summaries: [s], items: const [], now: now);
      final due = plan.dues.single;
      expect(due.noPlan, isTrue);
      expect(plan.totalDue, 0);
      expect(plan.totalPaid, 0);
    });
  });

  group('MonthPlan — recurring items', () {
    test('an item due later this month is an unpaid due at its actual amount', () {
      final item = recurringItem(nextDueDate: DateTime(2026, 7, 20));
      final plan = MonthPlan.from(summaries: const [], items: [item], now: now);
      final due = plan.dues.single;
      expect(due.source, MonthDueSource.recurring);
      expect(due.dueDate, DateTime(2026, 7, 20));
      expect(due.amountDue, 499);
      expect(due.isPaid, isFalse);
    });

    test('a monthly item already advanced past July was paid this month', () {
      // nextDueDate 5 Aug → rolled-back 5 Jul lands in July ⇒ inferred paid.
      final item = recurringItem(nextDueDate: DateTime(2026, 8, 5));
      final plan = MonthPlan.from(summaries: const [], items: [item], now: now);
      final due = plan.dues.single;
      expect(due.dueDate, DateTime(2026, 7, 5));
      expect(due.isPaid, isTrue);
      expect(plan.totalPaid, 499);
    });

    test('a quarterly item not due this month is absent', () {
      final item = recurringItem(
        frequency: Frequency.quarterly,
        nextDueDate: DateTime(2026, 9, 1),
      );
      final plan = MonthPlan.from(summaries: const [], items: [item], now: now);
      expect(plan.dues, isEmpty);
      expect(plan.carriedOver, 0);
    });

    test('a yearly item due this month appears at its full amount', () {
      final item = recurringItem(
        amount: 12000,
        frequency: Frequency.yearly,
        nextDueDate: DateTime(2026, 7, 20),
      );
      final plan = MonthPlan.from(summaries: const [], items: [item], now: now);
      expect(plan.dues.single.amountDue, 12000);
      expect(plan.totalDue, 12000);
    });

    test('weekly items land multiple times; inferred paids respect createdAt', () {
      // Due 22 Jul, weekly. Future in-July dues: 22 & 29 Jul. Rolled-back paid
      // candidates: 15, 8, 1 Jul — but the item was created 6 Jul, so only
      // 8 & 15 Jul were real paid occurrences.
      final item = recurringItem(
        amount: 100,
        frequency: Frequency.weekly,
        nextDueDate: DateTime(2026, 7, 22),
        createdAt: DateTime(2026, 7, 6),
      );
      final plan = MonthPlan.from(summaries: const [], items: [item], now: now);
      expect(plan.dues, hasLength(4));
      final paid = plan.dues.where((d) => d.isPaid).toList();
      final pending = plan.dues.where((d) => !d.isPaid).toList();
      expect(paid.map((d) => d.dueDate), [
        DateTime(2026, 7, 8),
        DateTime(2026, 7, 15),
      ]);
      expect(pending.map((d) => d.dueDate), [
        DateTime(2026, 7, 22),
        DateTime(2026, 7, 29),
      ]);
      expect(plan.totalDue, 400);
      expect(plan.totalPaid, 200);
    });

    test('an overdue item from a previous month is carry-over, not a July due', () {
      final item = recurringItem(nextDueDate: DateTime(2026, 6, 10));
      final plan = MonthPlan.from(summaries: const [], items: [item], now: now);
      expect(plan.dues, isEmpty);
      expect(plan.carriedOver, 499);
    });

    test('inactive items contribute nothing', () {
      final item = recurringItem(
        isActive: false,
        nextDueDate: DateTime(2026, 7, 20),
      );
      final plan = MonthPlan.from(summaries: const [], items: [item], now: now);
      expect(plan.dues, isEmpty);
    });
  });

  group('MonthPlan — card bills fold in linked EMIs', () {
    final icici = CardAccount(
      id: 'c1',
      lenderId: 'l-icici',
      name: 'ICICI Amazon Pay',
      statementDay: 15,
      dueDay: 20,
      createdAt: DateTime(2026, 1, 1),
    );
    // Cycle Jul: window (15 Jun, 15 Jul], bill due 20 Jul (inside July).
    final julyStatement = CardStatement(
      id: 's1',
      cardId: 'c1',
      cycleMonth: DateTime(2026, 7),
      statementAmount: 18400,
      dueDate: DateTime(2026, 7, 20),
    );
    // EMI on the card: #1 due 1 Jul → billed on the July statement.
    final cardEmi = emiSummary(
      startDate: DateTime(2026, 6, 1),
      lenderId: 'l-icici',
    );

    test('one card-bill due; the linked EMI row is folded, never counted twice',
        () {
      final plan = MonthPlan.from(
        summaries: [cardEmi],
        items: const [],
        now: now,
        cards: [icici],
        statements: [julyStatement],
      );
      final due = plan.dues.single;
      expect(due.source, MonthDueSource.cardBill);
      expect(due.category, ObligationCategory.card);
      expect(due.amountDue, 18400);
      expect(due.foldedAmount, closeTo(1000, 0.001));
      expect(due.dueDate, DateTime(2026, 7, 20));
      expect(plan.totalDue, 18400);
    });

    test('partially paid bill reflects on the row and totals', () {
      final plan = MonthPlan.from(
        summaries: [cardEmi],
        items: const [],
        now: now,
        cards: [icici],
        statements: [julyStatement.copyWith(paidAmount: 5000)],
      );
      expect(plan.dues.single.amountPaid, 5000);
      expect(plan.totalPaid, 5000);
      expect(plan.remaining, closeTo(13400, 0.001));
    });

    test('no statement entered → the EMI row shows individually as before', () {
      final plan = MonthPlan.from(
        summaries: [cardEmi],
        items: const [],
        now: now,
        cards: [icici],
        statements: const [],
      );
      expect(plan.dues.single.source, MonthDueSource.emiInstallment);
      expect(plan.totalDue, closeTo(1000, 0.001));
    });

    test('a statement due next month folds the EMI out of this month too', () {
      // dueDay 3 → the July-cycle bill is due 3 Aug: the EMI money leaves with
      // that bill, so July shows nothing and August shows the card bill.
      final earlyDue = CardAccount(
        id: 'c1',
        lenderId: 'l-icici',
        name: 'ICICI Amazon Pay',
        statementDay: 15,
        dueDay: 3,
        createdAt: DateTime(2026, 1, 1),
      );
      final augustBill = CardStatement(
        id: 's1',
        cardId: 'c1',
        cycleMonth: DateTime(2026, 7),
        statementAmount: 18400,
        dueDate: DateTime(2026, 8, 3),
      );
      final july = MonthPlan.from(
        summaries: [cardEmi],
        items: const [],
        now: now,
        cards: [earlyDue],
        statements: [augustBill],
      );
      expect(july.dues, isEmpty);

      final august = MonthPlan.from(
        summaries: [cardEmi],
        items: const [],
        now: DateTime(2026, 8, 15),
        cards: [earlyDue],
        statements: [augustBill],
      );
      // August carries the July-cycle bill (covering EMI #1) AND EMI #2 as an
      // individual row — #2 belongs to the August cycle, whose statement
      // isn't entered yet. No rupee appears twice.
      expect(
        august.dues.map((d) => d.source),
        containsAll(
          [MonthDueSource.cardBill, MonthDueSource.emiInstallment],
        ),
      );
      expect(august.dues, hasLength(2));
    });

    test('an unlinked EMI is untouched by card statements', () {
      final other = emiSummary(
        id: 'emi-2',
        startDate: DateTime(2026, 6, 1),
        lenderId: 'l-hdfc',
      );
      final plan = MonthPlan.from(
        summaries: [other],
        items: const [],
        now: now,
        cards: [icici],
        statements: [julyStatement],
      );
      expect(
        plan.dues.map((d) => d.source),
        containsAll([MonthDueSource.cardBill, MonthDueSource.emiInstallment]),
      );
      expect(plan.totalDue, closeTo(18400 + 1000, 0.001));
    });

    test('a subscription linked to the card is folded out, not double-counted',
        () {
      // Netflix due 1 Jul, inside the July window, billed on this card. It is
      // already inside the 18400 statement, so it must NOT add its own row.
      final linkedSub = recurringItem(
        id: 'netflix',
        amount: 499,
        nextDueDate: DateTime(2026, 7, 1),
        cardId: 'c1',
      );
      final plan = MonthPlan.from(
        summaries: const [],
        items: [linkedSub],
        now: now,
        cards: [icici],
        statements: [julyStatement],
      );
      final due = plan.dues.single;
      expect(due.source, MonthDueSource.cardBill);
      expect(due.foldedAmount, closeTo(499, 0.001));
      expect(plan.totalDue, 18400); // not 18400 + 499
    });

    test('an unlinked subscription still shows its own row', () {
      final freeSub = recurringItem(
        id: 'spotify',
        amount: 199,
        nextDueDate: DateTime(2026, 7, 1),
      );
      final plan = MonthPlan.from(
        summaries: const [],
        items: [freeSub],
        now: now,
        cards: [icici],
        statements: [julyStatement],
      );
      expect(
        plan.dues.map((d) => d.source),
        containsAll([MonthDueSource.cardBill, MonthDueSource.recurring]),
      );
      expect(plan.totalDue, closeTo(18400 + 199, 0.001));
    });
  });

  group('MonthPlan — ordering and totals', () {
    test('dated dues sort ascending, undated loans after, noPlan last', () {
      final emi = emiSummary(startDate: DateTime(2026, 6, 10)); // due 10 Jul
      final loan = loanSummary(startDate: DateTime(2026, 6, 1), minPayment: 2000);
      final noPlanLoan = loanSummary(
        id: 'loan-2',
        startDate: DateTime(2026, 6, 1),
        minPayment: 0,
      );
      final item = recurringItem(nextDueDate: DateTime(2026, 7, 5));
      final plan = MonthPlan.from(
        summaries: [emi, loan, noPlanLoan],
        items: [item],
        now: now,
      );
      expect(plan.dues.map((d) => d.sourceId).toList(), [
        'rec-1', // 5 Jul
        'emi-1', // 10 Jul
        'loan-1', // undated
        'loan-2', // noPlan
      ]);
      expect(plan.totalDue, closeTo(499 + 1000 + 2000, 0.001));
      expect(plan.progress, 0);
    });
  });
}
