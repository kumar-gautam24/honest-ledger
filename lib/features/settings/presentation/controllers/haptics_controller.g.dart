// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haptics_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether haptic feedback is on, persisted and applied to [HapticService].

@ProviderFor(HapticsController)
final hapticsControllerProvider = HapticsControllerProvider._();

/// Whether haptic feedback is on, persisted and applied to [HapticService].
final class HapticsControllerProvider
    extends $NotifierProvider<HapticsController, bool> {
  /// Whether haptic feedback is on, persisted and applied to [HapticService].
  HapticsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hapticsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hapticsControllerHash();

  @$internal
  @override
  HapticsController create() => HapticsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hapticsControllerHash() => r'e66e5823d7fffe721d7d2e643c0872af8ba3ba58';

/// Whether haptic feedback is on, persisted and applied to [HapticService].

abstract class _$HapticsController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
