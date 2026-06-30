/// Low-level exceptions thrown inside the data layer and mapped to
/// [Failure]s by repositories. Not shown to users directly.
class StorageException implements Exception {
  const StorageException([this.message = 'Local storage error']);
  final String message;
  @override
  String toString() => 'StorageException: $message';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'Network error']);
  final String message;
  @override
  String toString() => 'NetworkException: $message';
}
