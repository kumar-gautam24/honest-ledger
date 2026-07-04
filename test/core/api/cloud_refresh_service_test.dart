import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/auth_token_store.dart';
import 'package:recurring/core/api/cloud_backed_repository.dart';
import 'package:recurring/core/api/cloud_refresh_service_impl.dart';
import 'package:recurring/features/settings/data/settings_remote_source.dart';
import 'package:recurring/features/settings/presentation/controllers/income_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Repo implements CloudBackedRepository {
  _Repo({this.throws = false});
  final bool throws;
  int pulls = 0;
  @override
  Future<void> pullFromCloud() async {
    pulls++;
    if (throws) throw Exception('feature down');
  }
}

class _Settings implements SettingsRemoteSource {
  _Settings(this.income);
  final double? income;
  @override
  Future<double?> fetchIncome() async => income;
  @override
  Future<void> pushIncome(double rupees) async {}
  @override
  Future<void> clearIncome() async {}
}

class _Tokens implements AuthTokenStore {
  _Tokens({this.signedIn = true});
  bool signedIn;
  @override
  bool get isSignedIn => signedIn;
  @override
  String? get accessToken => signedIn ? 'a' : null;
  @override
  String? get refreshToken => signedIn ? 'r' : null;
  @override
  String? get email => null;
  @override
  Future<void> save({required String accessToken, required String refreshToken, required String email}) async {}
  @override
  Future<void> updateAccessToken(String accessToken) async {}
  @override
  Future<void> clear() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> prefs() async {
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance();
  }

  test('signed out: pulls nothing', () async {
    final repo = _Repo();
    final service = CloudRefreshServiceImpl(
        [repo], _Settings(null), await prefs(), _Tokens(signedIn: false));
    await service.pullAll();
    expect(repo.pulls, 0);
  });

  test('pulls every repo and writes income to prefs', () async {
    final a = _Repo();
    final b = _Repo();
    final p = await prefs();
    final service =
        CloudRefreshServiceImpl([a, b], _Settings(50000), p, _Tokens());

    await service.pullAll();

    expect(a.pulls, 1);
    expect(b.pulls, 1);
    expect(p.getDouble(IncomeController.prefsKey), 50000);
  });

  test('one failing repo does not abort the others', () async {
    final failing = _Repo(throws: true);
    final ok = _Repo();
    final service = CloudRefreshServiceImpl(
        [failing, ok], _Settings(null), await prefs(), _Tokens());

    await service.pullAll(); // must not throw

    expect(ok.pulls, 1);
  });
}
