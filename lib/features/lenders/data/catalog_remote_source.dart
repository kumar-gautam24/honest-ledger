import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../domain/entities/lender.dart';
import 'lender_remote_source.dart';

/// One version-stamped snapshot of the global catalog.
typedef CatalogSnapshot = ({int version, List<Lender> items});

/// Reads the GLOBAL, server-managed lender catalog (`/v1/catalog`). Reads are
/// PUBLIC — no auth needed — so this works signed-out. It lets term corrections
/// (a wrong rate, a new issuer) reach users WITHOUT an app update, with the
/// built-in [kSeedLenders] as the offline fallback. Writes stay admin-only and
/// are not modelled here.
abstract interface class CatalogRemoteSource {
  /// Cheap poll: the catalog's current version (MAX row version, 0 when empty).
  Future<int> fetchVersion();

  /// The active catalog and its version. Reuses [lenderFromJson]; the catalog
  /// omits `is_mine` (a per-user concept), so every item maps to `isMine=false`.
  Future<CatalogSnapshot> fetchCatalog();
}

class CatalogRemoteSourceDio implements CatalogRemoteSource {
  CatalogRemoteSourceDio(this._client);

  final ApiClient _client;
  Dio get _dio => _client.dio;

  @override
  Future<int> fetchVersion() async {
    final response = await _dio.get<dynamic>('/v1/catalog/version');
    final data = response.data as Map<String, dynamic>;
    return ((data['version'] as num?) ?? 0).toInt();
  }

  @override
  Future<CatalogSnapshot> fetchCatalog() async {
    final response = await _dio.get<dynamic>('/v1/catalog/lenders');
    final data = response.data as Map<String, dynamic>;
    final items = ((data['items'] as List?) ?? const [])
        .map((e) => lenderFromJson(e as Map<String, dynamic>))
        .toList();
    return (version: ((data['version'] as num?) ?? 0).toInt(), items: items);
  }
}
