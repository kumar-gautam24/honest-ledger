/// A small, transport-agnostic error the data layer can catch without knowing
/// about Dio. Remote sources translate Dio failures into this; callers that do
/// best-effort pushes simply swallow it and rely on the local cache.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
