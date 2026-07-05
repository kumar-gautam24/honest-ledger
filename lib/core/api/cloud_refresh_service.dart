/// Pulls the whole account down from the backend into the local Drift cache.
///
/// Interface declared here so the auth session can trigger a pull on sign-in
/// without depending on the concrete implementation (wired later in DI).
abstract interface class CloudRefreshService {
  /// Best-effort: pulls every feature; a failure in one does not abort the rest.
  Future<void> pullAll();

  /// Uploads all locally-stored rows to the backend, back-filling anything
  /// created before sign-in. Best-effort: one feature failing does not abort the
  /// rest. Run before [pullAll] on sign-in so local data reaches the cloud before
  /// the cloud is merged back into the local cache.
  Future<void> pushAll();
}
