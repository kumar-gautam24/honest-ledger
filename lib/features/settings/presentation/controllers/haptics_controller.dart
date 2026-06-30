import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';

part 'haptics_controller.g.dart';

/// Whether haptic feedback is on, persisted and applied to [HapticService].
@riverpod
class HapticsController extends _$HapticsController {
  static const _key = 'haptics_enabled';

  @override
  bool build() {
    final enabled = sl<SharedPreferences>().getBool(_key) ?? true;
    sl<HapticService>().enabled = enabled;
    return enabled;
  }

  Future<void> set(bool enabled) async {
    state = enabled;
    sl<HapticService>().enabled = enabled;
    await sl<SharedPreferences>().setBool(_key, enabled);
  }
}
