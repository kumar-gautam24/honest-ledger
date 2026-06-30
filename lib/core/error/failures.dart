/// A user-facing failure produced by the data layer.
///
/// Repositories catch low-level [Exception]s and surface a [Failure] so the
/// presentation layer can show a clean message without knowing about Drift,
/// Dio, or platform errors.
sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// Local database read/write failure.
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Could not access local data.']);
}

/// Remote/network failure (used once the backend lands).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network request failed.']);
}

/// Input that passed UI validation but was rejected deeper in the stack.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Anything unexpected.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}
