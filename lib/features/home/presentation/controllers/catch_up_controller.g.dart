// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catch_up_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Everything that went past before this month without being logged.

@ProviderFor(catchUp)
final catchUpProvider = CatchUpProvider._();

/// Everything that went past before this month without being logged.

final class CatchUpProvider
    extends $FunctionalProvider<CatchUp, CatchUp, CatchUp>
    with $Provider<CatchUp> {
  /// Everything that went past before this month without being logged.
  CatchUpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catchUpProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catchUpHash();

  @$internal
  @override
  $ProviderElement<CatchUp> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CatchUp create(Ref ref) {
    return catchUp(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatchUp value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatchUp>(value),
    );
  }
}

String _$catchUpHash() => r'a66cb586546d443138b9d52296bdede67c830c90';
