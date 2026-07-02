// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Optional monthly income, persisted. Null = not set; powers the
/// "left after obligations" line on Home and the %-of-income line on
/// This Month — nothing else.

@ProviderFor(IncomeController)
final incomeControllerProvider = IncomeControllerProvider._();

/// Optional monthly income, persisted. Null = not set; powers the
/// "left after obligations" line on Home and the %-of-income line on
/// This Month — nothing else.
final class IncomeControllerProvider
    extends $NotifierProvider<IncomeController, double?> {
  /// Optional monthly income, persisted. Null = not set; powers the
  /// "left after obligations" line on Home and the %-of-income line on
  /// This Month — nothing else.
  IncomeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeControllerHash();

  @$internal
  @override
  IncomeController create() => IncomeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double?>(value),
    );
  }
}

String _$incomeControllerHash() => r'1f4cf592024eac20d92327179838e9a823128915';

/// Optional monthly income, persisted. Null = not set; powers the
/// "left after obligations" line on Home and the %-of-income line on
/// This Month — nothing else.

abstract class _$IncomeController extends $Notifier<double?> {
  double? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double?, double?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double?, double?>,
              double?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
