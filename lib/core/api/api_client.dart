import 'package:dio/dio.dart';

import 'api_config.dart';
import 'auth_token_store.dart';

/// The app's single configured [Dio]. Every remote source is built on this, so
/// auth and base URL are handled in one place.
///
/// The interceptor does two things:
///   1. attaches `Authorization: Bearer <access>` when the user is signed in;
///   2. on a 401, silently refreshes the access token once (rotating the refresh
///      token) and retries the original request. If refresh fails, it clears the
///      tokens (effectively signing out) and lets the error surface.
class ApiClient {
  ApiClient(this._tokenStore, {Dio? dio, Dio? refreshDio})
      : dio = dio ?? _defaultDio(),
        // A bare Dio (no auth interceptor) is used for the refresh call itself,
        // so refreshing can never recurse back into this interceptor.
        _refreshDio = refreshDio ?? _defaultDio() {
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: _onRequest,
            onError: _onError,
          ),
        );
  }

  final Dio dio;
  final Dio _refreshDio;
  final AuthTokenStore _tokenStore;

  static Dio _defaultDio() => Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          // We handle non-2xx ourselves (esp. 401), so don't let Dio throw before
          // the error interceptor runs.
          headers: {'Content-Type': 'application/json'},
        ),
      );

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenStore.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthError = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['__retried__'] == true;
    final refreshToken = _tokenStore.refreshToken;

    if (!isAuthError || alreadyRetried || refreshToken == null) {
      handler.next(err);
      return;
    }

    final refreshed = await _tryRefresh(refreshToken);
    if (!refreshed) {
      // Refresh failed: the session is dead. Clear it and surface the error.
      await _tokenStore.clear();
      handler.next(err);
      return;
    }

    try {
      final response = await _retry(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }

  /// Exchanges the refresh token for a fresh access+refresh pair (the backend
  /// rotates refresh tokens). Returns whether it succeeded.
  Future<bool> _tryRefresh(String refreshToken) async {
    try {
      final response = await _refreshDio.post(
        '/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      final email = _tokenStore.email ?? '';
      await _tokenStore.save(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        email: email,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options) {
    final token = _tokenStore.accessToken;
    return dio.request<dynamic>(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: {
          ...options.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        extra: {...options.extra, '__retried__': true},
      ),
    );
  }
}
