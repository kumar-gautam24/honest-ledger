import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/features/recurring/data/recurring_repository_impl.dart';
import 'package:recurring/features/recurring/domain/entities/recurring_item.dart';
import 'package:recurring/features/recurring/domain/entities/recurring_stats.dart';

RecurringItem _item(
  String id,
  double amount,
  Frequency freq, {
  bool active = true,
}) =>
    RecurringItem(
      id: id,
      title: id,
      amount: amount,
      frequency: freq,
      isActive: active,
      nextDueDate: DateTime(2026, 1, 15),
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('RecurringStats normalises every frequency to a monthly figure', () {
    test('mixed frequencies sum correctly', () {
      final stats = RecurringStats.from([
        _item('weekly', 100, Frequency.weekly), // 100*52/12 = 433.33
        _item('monthly', 500, Frequency.monthly), // 500
        _item('quarterly', 300, Frequency.quarterly), // 300*4/12 = 100
        _item('yearly', 1200, Frequency.yearly), // 1200/12 = 100
      ]);
      expect(stats.monthlyOutflow, closeTo(1133.33, 0.01));
      expect(stats.activeCount, 4);
    });

    test('inactive items are excluded from outflow', () {
      final stats = RecurringStats.from([
        _item('a', 500, Frequency.monthly),
        _item('b', 999, Frequency.monthly, active: false),
      ]);
      expect(stats.monthlyOutflow, 500);
      expect(stats.activeCount, 1);
    });
  });

  test('advanceDue rolls a monthly item forward by one month', () {
    final next = _item('x', 100, Frequency.monthly).advanceDue();
    expect(next, DateTime(2026, 2, 15));
  });

  group('repository persists and updates', () {
    late AppDatabase db;
    late RecurringRepositoryImpl repo;

    setUp(() {
      db = AppDatabase.memory();
      repo = RecurringRepositoryImpl(db);
    });
    tearDown(() => db.close());

    test('upsert then delete', () async {
      await repo.upsert(_item('n', 199, Frequency.monthly));
      expect(await repo.watchAll().first, hasLength(1));

      await repo.delete('n');
      expect(await repo.watchAll().first, isEmpty);
    });
  });
}
