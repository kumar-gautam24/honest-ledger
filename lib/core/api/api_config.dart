/// Backend connection settings.
///
/// [baseUrl] points at the FastAPI backend. Default is localhost for development.
/// On a physical device or Android emulator this must change (Android emulator
/// reaches the host at http://10.0.2.2:8000); we make it a single const now and
/// will lift it to build config when we deploy.
class ApiConfig {
  const ApiConfig._();

  // ngrok tunnel to the local FastAPI (free plan: this subdomain changes on every
  // `ngrok http 8000` restart — re-paste the new URL when it does). HTTPS keeps
  // iOS App Transport Security happy on physical devices.
  static const String baseUrl = 'https://backspin-derail-icing.ngrok-free.dev';

  /// How long to wait before treating a call as failed. Kept short so a down or
  /// unreachable backend falls back to the local cache quickly instead of hanging.
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
