import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/auth_token_store.dart';
import 'package:recurring/core/api/cloud_backed_repository.dart';
import 'package:recurring/core/api/cloud_refresh_service_impl.dart';
import 'package:recurring/features/settings/data/settings_remote_source.dart';
import 'package:recurring/features/settings/presentation/controllers/income_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Repo implements CloudBackedRepository {
  _Repo({this.throws = false, this.throwsOnPush = false});
  final bool throws;
  final bool throwsOnPush;
  int pulls = 0;
  int pushes = 0;
  @override
  Future<void> pullFromCloud() async {
    pulls++;
    if (throws) throw Exception('feature down');
  }

  @override
  Future<void> pushToCloud() async {
    pushes++;
    if (throwsOnPush) throw Exception('feature down');
  }
}

class _Settings implements SettingsRemoteSource {
  _Settings(this.income);
  final double? income;
  double? pushedIncome;
  bool cleared = false;
  @override
  Future<double?> fetchIncome() async => income;
  @override
  Future<void> pushIncome(double rupees) async => pushedIncome = rupees;
  @override
  Future<void> clearIncome() async => cleared = true;
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

  group('pushAll', () {
    test('signed out: pushes nothing', () async {
      final repo = _Repo();
      final service = CloudRefreshServiceImpl(
          [repo], _Settings(null), await prefs(), _Tokens(signedIn: false));

      await service.pushAll();

      expect(repo.pushes, 0);
    });

    test('pushes every repo and uploads local income', () async {
      final a = _Repo();
      final b = _Repo();
      SharedPreferences.setMockInitialValues(
          {IncomeController.prefsKey: 42000.0});
      final settings = _Settings(null);
      final service = CloudRefreshServiceImpl(
          [a, b], settings, await SharedPreferences.getInstance(), _Tokens());

      await service.pushAll();

      expect(a.pushes, 1);
      expect(b.pushes, 1);
      expect(settings.pushedIncome, 42000.0);
    });

    test('no local income: never clears the cloud value', () async {
      final settings = _Settings(99000); // cloud has an income
      final service = CloudRefreshServiceImpl(
          [_Repo()], settings, await prefs(), _Tokens());

      await service.pushAll();

      expect(settings.cleared, isFalse);
      expect(settings.pushedIncome, isNull);
    });

    test('one failing repo does not abort the others', () async {
      final failing = _Repo(throwsOnPush: true);
      final ok = _Repo();
      final service = CloudRefreshServiceImpl(
          [failing, ok], _Settings(null), await prefs(), _Tokens());

      await service.pushAll(); // must not throw

      expect(ok.pushes, 1);
    });
  });
}
