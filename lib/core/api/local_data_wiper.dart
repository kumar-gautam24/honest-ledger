import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/presentation/controllers/income_controller.dart';
import '../database/app_database.dart';

/// Clears the signed-in account's data from local storage — used on sign-out so
/// signing into a different account can't inherit (or upload) the previous one's
/// rows. Wipes the account tables and the income pref, but keeps the built-in
/// lender catalog (global, `isMine = false`) and device prefs (theme, haptics).
abstract interface class LocalDataWiper {
  Future<void> wipe();
}

class LocalDataWiperImpl implements LocalDataWiper {
  LocalDataWiperImpl(this._db, this._prefs);

  final AppDatabase _db;
  final SharedPreferences _prefs;

  @override
  Future<void> wipe() async {
    await _db.transaction(() async {
      // Children before parents (foreign keys are enforced).
      await _db.delete(_db.repayments).go();
      await _db.delete(_db.cardStatements).go();
      await _db.delete(_db.borrowings).go();
      await _db.delete(_db.cards).go();
      await _db.delete(_db.recurringItems).go();
      // Keep the built-in catalog; drop only the user's own lenders.
      await (_db.delete(_db.lenders)..where((t) => t.isMine.equals(true))).go();
    });
    await _prefs.remove(IncomeController.prefsKey);
  }
}
