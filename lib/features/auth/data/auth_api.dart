import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';

/// A fresh access + refresh token pair from the backend.
class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

/// Talks to `/v1/auth/*`. Register returns no tokens (the caller logs in after),
/// mirroring the backend: register creates the account, login mints the tokens.
class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;
  Dio get _dio => _client.dio;

  Future<void> register(String email, String password) async {
    try {
      await _dio.post<dynamic>(
        '/v1/auth/register',
        data: {'email': email, 'password': password},
      );
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<TokenPair> login(String email, String password) async {
    try {
      final response = await _dio.post<dynamic>(
        '/v1/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      return TokenPair(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<dynamic>(
        '/v1/auth/logout',
        data: {'refresh_token': refreshToken},
      );
    } on DioException catch (_) {
      // Best-effort: even if the server call fails, the caller clears local tokens.
    }
  }

  ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    var message = 'Could not reach the server';
    if (data is Map && data['error'] is Map && data['error']['message'] != null) {
      message = data['error']['message'].toString();
    }
    return ApiException(message, statusCode: status);
  }
}
