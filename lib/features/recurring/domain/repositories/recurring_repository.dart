import '../entities/recurring_item.dart';

/// Read/write access to recurring items.
abstract interface class RecurringRepository {
  /// Active items first, then by next due date.
  Stream<List<RecurringItem>> watchAll();

  Future<void> upsert(RecurringItem item);

  Future<void> delete(String id);
}
