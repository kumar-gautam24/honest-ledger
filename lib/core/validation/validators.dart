/// A form-field validator: returns an error message, or null when valid.
typedef StringValidator = String? Function(String? value);

/// Composable, reusable validators. Forms build their rules from these instead
/// of writing one-off closures, so messages and behaviour stay consistent.
abstract final class Validators {
  static double? _parse(String? v) {
    if (v == null) return null;
    return double.tryParse(v.replaceAll(',', '').trim());
  }

  static StringValidator required([String message = 'Required']) {
    return (v) => (v == null || v.trim().isEmpty) ? message : null;
  }

  static StringValidator number([String message = 'Enter a valid number']) {
    return (v) {
      if (v == null || v.trim().isEmpty) return null; // pair with required()
      return _parse(v) == null ? message : null;
    };
  }

  static StringValidator positive([
    String message = 'Enter an amount greater than 0',
  ]) {
    return (v) {
      final n = _parse(v);
      if (n == null) return null;
      return n <= 0 ? message : null;
    };
  }

  static StringValidator min(double minValue, {String? message}) {
    return (v) {
      final n = _parse(v);
      if (n == null) return null;
      return n < minValue ? (message ?? 'Must be at least $minValue') : null;
    };
  }

  static StringValidator range(double lo, double hi, {String? message}) {
    return (v) {
      final n = _parse(v);
      if (n == null) return null;
      return (n < lo || n > hi)
          ? (message ?? 'Enter a value between $lo and $hi')
          : null;
    };
  }

  static StringValidator integer([String message = 'Enter a whole number']) {
    return (v) {
      if (v == null || v.trim().isEmpty) return null;
      return int.tryParse(v.trim()) == null ? message : null;
    };
  }

  /// Runs validators in order and returns the first failure.
  static StringValidator combine(List<StringValidator> validators) {
    return (v) {
      for (final validate in validators) {
        final error = validate(v);
        if (error != null) return error;
      }
      return null;
    };
  }
}
