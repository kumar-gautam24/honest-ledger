// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recurringRepository)
final recurringRepositoryProvider = RecurringRepositoryProvider._();

final class RecurringRepositoryProvider
    extends
        $FunctionalProvider<
          RecurringRepository,
          RecurringRepository,
          RecurringRepository
        >
    with $Provider<RecurringRepository> {
  RecurringRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecurringRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringRepository create(Ref ref) {
    return recurringRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringRepository>(value),
    );
  }
}

String _$recurringRepositoryHash() =>
    r'681b96f3a14a7afe2b20f72d0d5c31b977010e16';

@ProviderFor(recurringItems)
final recurringItemsProvider = RecurringItemsProvider._();

final class RecurringItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecurringItem>>,
          List<RecurringItem>,
          Stream<List<RecurringItem>>
        >
    with
        $FutureModifier<List<RecurringItem>>,
        $StreamProvider<List<RecurringItem>> {
  RecurringItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<RecurringItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecurringItem>> create(Ref ref) {
    return recurringItems(ref);
  }
}

String _$recurringItemsHash() => r'4e04ef2f459534595f53349521b77b55824db011';

@ProviderFor(recurringStats)
final recurringStatsProvider = RecurringStatsProvider._();

final class RecurringStatsProvider
    extends $FunctionalProvider<RecurringStats, RecurringStats, RecurringStats>
    with $Provider<RecurringStats> {
  RecurringStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringStatsHash();

  @$internal
  @override
  $ProviderElement<RecurringStats> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecurringStats create(Ref ref) {
    return recurringStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringStats>(value),
    );
  }
}

String _$recurringStatsHash() => r'b1340f1a5ffc3b1f579d26f8131505d4a6b96217';
