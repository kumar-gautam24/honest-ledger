import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/features/home/domain/entities/catch_up.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';

import 'fixtures.dart';

void main() {
  final now = DateTime(2026, 7, 15);

  group('CatchUp.from', () {
    test('unpaid EMI installments from before this month, not this month\'s', () {
      // Started 1 Mar → #1..#3 due Apr–Jun are arrears; #4 (1 Jul) belongs to
      // the month plan, not catch-up.
      final s = emiSummary(startDate: DateTime(2026, 3, 1));
      final catchUp =
          CatchUp.from(summaries: [s], items: const [], now: now);
      expect(catchUp.items, hasLength(3));
      expect(
        catchUp.items.map((i) => i.dueDate),
        [DateTime(2026, 4, 1), DateTime(2026, 5, 1), DateTime(2026, 6, 1)],
      );
      expect(catchUp.items.first.installmentNo, 1);
      expect(catchUp.total, closeTo(3000, 0.001));
      expect(catchUp.emiCount, 3);
      expect(catchUp.recurringCount, 0);
      expect(catchUp.isEmpty, isFalse);
    });

    test('paid installments and closed borrowings are not arrears', () {
      final paid = emiSummary(
        startDate: DateTime(2026, 3, 1),
        paidInstallments: 3,
      );
      final closed = emiSummary(
        id: 'e2',
        startDate: DateTime(2026, 3, 1),
        status: BorrowingStatus.closed,
      );
      final catchUp =
          CatchUp.from(summaries: [paid, closed], items: const [], now: now);
      expect(catchUp.isEmpty, isTrue);
    });

    test('recurring cycles behind roll forward to just before this month', () {
      // Monthly, nextDueDate 10 May → missed 10 May and 10 Jun.
      final item = recurringItem(nextDueDate: DateTime(2026, 5, 10));
      final catchUp =
          CatchUp.from(summaries: const [], items: [item], now: now);
      expect(catchUp.items, hasLength(2));
      expect(
        catchUp.items.map((i) => i.dueDate),
        [DateTime(2026, 5, 10), DateTime(2026, 6, 10)],
      );
      expect(catchUp.total, closeTo(998, 0.001));
      expect(catchUp.recurringCount, 2);
    });

    test('inactive items and current-month dues are not arrears', () {
      final inactive = recurringItem(
        isActive: false,
        nextDueDate: DateTime(2026, 5, 10),
      );
      final thisMonth = recurringItem(
        id: 'r2',
        nextDueDate: DateTime(2026, 7, 10),
      );
      final catchUp = CatchUp.from(
        summaries: const [],
        items: [inactive, thisMonth],
        now: now,
      );
      expect(catchUp.isEmpty, isTrue);
    });

    test('flexible loans are never catch-up items — no fixed schedule', () {
      final loan = loanSummary(startDate: DateTime(2026, 1, 1));
      final catchUp =
          CatchUp.from(summaries: [loan], items: const [], now: now);
      expect(catchUp.isEmpty, isTrue);
    });

    test('items are sorted oldest first across sources', () {
      final s = emiSummary(startDate: DateTime(2026, 4, 1)); // #1 due 1 May
      final item = recurringItem(nextDueDate: DateTime(2026, 4, 10));
      final catchUp =
          CatchUp.from(summaries: [s], items: [item], now: now);
      expect(
        catchUp.items.map((i) => i.dueDate),
        [
          DateTime(2026, 4, 10), // recurring Apr
          DateTime(2026, 5, 1), // EMI #1
          DateTime(2026, 5, 10), // recurring May
          DateTime(2026, 6, 1), // EMI #2
          DateTime(2026, 6, 10), // recurring Jun
        ],
      );
    });
  });
}
