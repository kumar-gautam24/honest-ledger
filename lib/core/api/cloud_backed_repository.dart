/// Marker for a repository that can pull its data from the backend into the local
/// cache. The refresh service pulls them all uniformly, without knowing each type.
abstract interface class CloudBackedRepository {
  /// Fetch this feature's rows from the API and write them into local storage.
  /// Best-effort: throws on network failure so the caller can log and move on.
  Future<void> pullFromCloud();

  /// Push every locally-stored row for this feature up to the backend. Used to
  /// back-fill data that was created while signed out (whose background push was
  /// skipped), so a later sign-in uploads it instead of leaving it orphaned.
  /// Parents are pushed before their children. Throws on network failure so the
  /// caller can log and move on.
  Future<void> pushToCloud();
}
