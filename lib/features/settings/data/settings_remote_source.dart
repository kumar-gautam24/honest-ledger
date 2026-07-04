import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/money_json.dart';

/// Talks to `/v1/settings` — the per-user key-value store. Income is stored under
/// the key `income` as integer paise. Kept tiny and income-specific for now.
abstract interface class SettingsRemoteSource {
  /// The stored monthly income in rupees, or null if unset.
  Future<double?> fetchIncome();
  Future<void> pushIncome(double rupees);
  Future<void> clearIncome();
}

class SettingsRemoteSourceDio implements SettingsRemoteSource {
  SettingsRemoteSourceDio(this._client);

  final ApiClient _client;
  Dio get _dio => _client.dio;

  static const _incomeKey = 'income';

  @override
  Future<double?> fetchIncome() async {
    final response = await _dio.get<dynamic>('/v1/settings');
    final items = (response.data as Map<String, dynamic>)['items'] as List;
    for (final item in items) {
      final map = item as Map<String, dynamic>;
      if (map['key'] == _incomeKey) {
        final paise = map['value'] as int;
        return paiseToRupees(paise);
      }
    }
    return null;
  }

  @override
  Future<void> pushIncome(double rupees) async {
    await _dio.put<dynamic>(
      '/v1/settings/$_incomeKey',
      data: {
        'value': rupeesToPaise(rupees),
        'updated_at': formatApiDate(DateTime.now().toUtc()),
      },
    );
  }

  @override
  Future<void> clearIncome() async {
    await _dio.delete<dynamic>('/v1/settings/$_incomeKey');
  }
}
