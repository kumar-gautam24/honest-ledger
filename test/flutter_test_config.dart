import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Auto-loaded by `flutter test` before every test in this package.
///
/// `flutter_secure_storage` talks to the OS over a platform channel that does
/// not exist in the unit-test environment, so any test that boots the app (and
/// thus constructs the real store) would throw `MissingPluginException`. We back
/// that channel with an in-memory map here, giving all tests a working secure
/// store without touching real device storage.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall call) async {
    final args = call.arguments as Map?;
    switch (call.method) {
      case 'read':
        return store[args!['key'] as String];
      case 'write':
        store[args!['key'] as String] = args['value'] as String;
        return null;
      case 'delete':
        store.remove(args!['key'] as String);
        return null;
      case 'readAll':
        return Map<String, String>.from(store);
      case 'deleteAll':
        store.clear();
        return null;
      case 'containsKey':
        return store.containsKey(args!['key'] as String);
      default:
        return null;
    }
  });

  await testMain();
}
