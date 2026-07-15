import 'package:shared_preferences/shared_preferences.dart';

import 'catalog_remote_source.dart';
import 'lender_repository_impl.dart';
import 'lender_seed.dart';

/// Pulls the server catalog into the local built-in lenders when it is newer
/// than what we last applied, so a rate/fee correction (or a whole new issuer)
/// reaches users WITHOUT an app release. The built-in [kSeedLenders] remains the
/// first-run / offline baseline; this only ever refines it.
///
/// Two invariants keep user data safe:
///  - **Ownership is local.** Which cards are "mine" (`isMine`) is a per-user
///    decision, not a catalog fact, so it is preserved across a refresh even
///    though the global catalog always reports `isMine=false`.
///  - **Only catalog rows are touched.** Upserts write server catalog entries;
///    removals are limited to shipped catalog ids the server has retired, and
///    never delete a card the user marked as theirs or a lender they added
///    (ids outside the catalog).
///
/// Writes go to the LOCAL repository, never the synced `/v1/lenders` store —
/// built-ins are server-side global data, not the user's custom lenders. Every
/// failure is swallowed: offline or a bad response leaves the seeded catalog in
/// place.
class CatalogRefreshService {
  CatalogRefreshService(this._remote, this._local, this._prefs);

  final CatalogRemoteSource _remote;

  /// The LOCAL, non-synced repository — writing here updates the on-device
  /// catalog without pushing built-ins to the per-user store.
  final LenderRepositoryImpl _local;
  final SharedPreferences _prefs;

  static const _versionKey = 'catalog_version';

  Future<void> refresh() async {
    try {
      final cached = _prefs.getInt(_versionKey) ?? 0;
      final serverVersion = await _remote.fetchVersion();
      if (serverVersion <= cached) return; // nothing new — skip the heavier call

      final snapshot = await _remote.fetchCatalog();
      // Never wipe the catalog on an empty/degraded response.
      if (snapshot.items.isEmpty) return;

      final serverIds = <String>{};
      for (final incoming in snapshot.items) {
        serverIds.add(incoming.id);
        // Terms come from the server; ownership stays whatever it is locally.
        final existing = await _local.getById(incoming.id);
        await _local.upsert(
          existing == null ? incoming : incoming.copyWith(isMine: existing.isMine),
        );
      }

      // Drop shipped built-ins the server has retired — but only genuine catalog
      // entries: never a card the user owns, never a user-added lender.
      for (final id in kSeedLenderIds) {
        if (serverIds.contains(id)) continue;
        final local = await _local.getById(id);
        if (local != null && !local.isMine) await _local.delete(id);
      }

      await _prefs.setInt(_versionKey, snapshot.version);
    } catch (_) {
      // Offline / server down / malformed payload: keep the seeded catalog.
    }
  }
}
