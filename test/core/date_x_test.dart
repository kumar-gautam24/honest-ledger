import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:recurring/core/utils/date_x.dart';

void main() {
  setUpAll(initializeDateFormatting);

  group('month helpers', () {
    test('monthStart drops the day and time', () {
      expect(DateTime(2026, 7, 15, 13, 45).monthStart, DateTime(2026, 7));
    });

    test('isSameMonth matches year+month only', () {
      expect(DateTime(2026, 7, 1).isSameMonth(DateTime(2026, 7, 31)), isTrue);
      expect(DateTime(2026, 7, 1).isSameMonth(DateTime(2026, 8, 1)), isFalse);
      expect(DateTime(2025, 7, 1).isSameMonth(DateTime(2026, 7, 1)), isFalse);
    });

    test('addMonths handles negative months', () {
      expect(DateTime(2026, 7, 20).addMonths(-12), DateTime(2025, 7, 20));
      expect(DateTime(2026, 1, 31).addMonths(-1), DateTime(2025, 12, 31));
      expect(DateTime(2026, 3, 31).addMonths(-1), DateTime(2026, 2, 28));
      expect(DateTime(2026, 7, 20).addMonths(-3), DateTime(2026, 4, 20));
    });

    test('monthYear and monthShort labels', () {
      expect(DateTime(2026, 7, 15).monthYear, 'July 2026');
      expect(DateTime(2026, 7, 15).monthShort, 'Jul');
    });
  });
}
