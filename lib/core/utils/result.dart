import '../error/failures.dart';

/// A lightweight success/failure type for repository and use-case returns.
///
/// Prefer this over throwing across layer boundaries: callers must handle both
/// arms via [fold] / [when], which keeps error handling explicit at the UI.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  /// Value if [Ok], else null.
  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => null,
      };

  /// Collapse both arms into a single value.
  R fold<R>(R Function(Failure failure) onErr, R Function(T value) onOk) {
    return switch (this) {
      Ok<T>(:final value) => onOk(value),
      Err<T>(:final failure) => onErr(failure),
    };
  }

  /// Transform the success value, preserving any failure.
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Ok<T>(:final value) => Ok(transform(value)),
      Err<T>(:final failure) => Err(failure),
    };
  }
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
