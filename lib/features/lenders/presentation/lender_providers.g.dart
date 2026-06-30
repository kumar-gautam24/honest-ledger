// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lender_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lenderRepository)
final lenderRepositoryProvider = LenderRepositoryProvider._();

final class LenderRepositoryProvider
    extends
        $FunctionalProvider<
          LenderRepository,
          LenderRepository,
          LenderRepository
        >
    with $Provider<LenderRepository> {
  LenderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lenderRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lenderRepositoryHash();

  @$internal
  @override
  $ProviderElement<LenderRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LenderRepository create(Ref ref) {
    return lenderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LenderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LenderRepository>(value),
    );
  }
}

String _$lenderRepositoryHash() => r'071e95b65e987b6a25fc2e4adf4c3317871072d0';

@ProviderFor(allLenders)
final allLendersProvider = AllLendersProvider._();

final class AllLendersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Lender>>,
          List<Lender>,
          Stream<List<Lender>>
        >
    with $FutureModifier<List<Lender>>, $StreamProvider<List<Lender>> {
  AllLendersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allLendersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allLendersHash();

  @$internal
  @override
  $StreamProviderElement<List<Lender>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Lender>> create(Ref ref) {
    return allLenders(ref);
  }
}

String _$allLendersHash() => r'e5c2ccabe7849489177c9122ba690644c57c2a8a';
