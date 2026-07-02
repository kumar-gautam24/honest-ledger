import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/features/home/domain/entities/lender_waste.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';

import 'fixtures.dart';

void main() {
  final start = DateTime(2026, 3, 1);

  group('LenderWaste.rank', () {
    test('aggregates borrowings of the same lender', () {
      // Fixture lender names: EMIs → 'Test Bank', loans → 'Test App'.
      final a = emiSummary(
        id: 'e1',
        startDate: start,
        principal: 120000,
        ratePct: 15,
        paidInstallments: 2,
      );
      final b = emiSummary(
        id: 'e2',
        startDate: start,
        principal: 60000,
        ratePct: 15,
        paidInstallments: 1,
      );
      final ranked = LenderWaste.rank([a, b]);
      expect(ranked, hasLength(1));
      expect(ranked.single.lenderName, 'Test Bank');
      expect(ranked.single.count, 2);
      expect(
        ranked.single.wastedSoFar,
        closeTo(a.wastedSoFar + b.wastedSoFar, 0.001),
      );
      expect(
        ranked.single.projectedExtra,
        closeTo(a.projectedExtra + b.projectedExtra, 0.001),
      );
    });

    test('ranks by projected extra, worst first', () {
      final cheap = emiSummary(id: 'e1', startDate: start); // 0% → no waste
      final costly = loanSummary(id: 'l1', startDate: start, ratePct: 36);
      final ranked = LenderWaste.rank([cheap, costly]);
      expect(ranked.first.lenderName, 'Test App');
    });

    test('closed borrowings still count — their waste is real history', () {
      final closed = emiSummary(
        startDate: start,
        principal: 120000,
        ratePct: 15,
        paidInstallments: 3,
        status: BorrowingStatus.closed,
      );
      final ranked = LenderWaste.rank([closed]);
      expect(ranked.single.wastedSoFar, greaterThan(0));
    });
  });
}
