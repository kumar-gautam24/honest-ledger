import '../entities/lender.dart';

/// Read/write access to the lender catalog.
abstract interface class LenderRepository {
  Stream<List<Lender>> watchAll();

  /// Only the user's own cards/accounts (`isMine`).
  Stream<List<Lender>> watchMine();

  Future<Lender?> getById(String id);

  Future<void> upsert(Lender lender);

  Future<void> delete(String id);
}
