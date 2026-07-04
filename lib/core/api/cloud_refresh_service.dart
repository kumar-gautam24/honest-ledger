/// Pulls the whole account down from the backend into the local Drift cache.
///
/// Interface declared here so the auth session can trigger a pull on sign-in
/// without depending on the concrete implementation (wired later in DI).
abstract interface class CloudRefreshService {
  /// Best-effort: pulls every feature; a failure in one does not abort the rest.
  Future<void> pullAll();
}
