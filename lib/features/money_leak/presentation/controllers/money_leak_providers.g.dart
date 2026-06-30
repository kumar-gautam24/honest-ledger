// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_leak_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(borrowingRepository)
final borrowingRepositoryProvider = BorrowingRepositoryProvider._();

final class BorrowingRepositoryProvider
    extends
        $FunctionalProvider<
          BorrowingRepository,
          BorrowingRepository,
          BorrowingRepository
        >
    with $Provider<BorrowingRepository> {
  BorrowingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'borrowingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$borrowingRepositoryHash();

  @$internal
  @override
  $ProviderElement<BorrowingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BorrowingRepository create(Ref ref) {
    return borrowingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BorrowingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BorrowingRepository>(value),
    );
  }
}

String _$borrowingRepositoryHash() =>
    r'15a3fbb29e349fd20026902732ff703ef9f30c96';

@ProviderFor(borrowingSummaries)
final borrowingSummariesProvider = BorrowingSummariesProvider._();

final class BorrowingSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BorrowingSummary>>,
          List<BorrowingSummary>,
          Stream<List<BorrowingSummary>>
        >
    with
        $FutureModifier<List<BorrowingSummary>>,
        $StreamProvider<List<BorrowingSummary>> {
  BorrowingSummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'borrowingSummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$borrowingSummariesHash();

  @$internal
  @override
  $StreamProviderElement<List<BorrowingSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BorrowingSummary>> create(Ref ref) {
    return borrowingSummaries(ref);
  }
}

String _$borrowingSummariesHash() =>
    r'7aacc6e696fdcd344bf7e3b9d1bb7fb47d7bdb7a';

@ProviderFor(borrowingSummary)
final borrowingSummaryProvider = BorrowingSummaryFamily._();

final class BorrowingSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<BorrowingSummary?>,
          BorrowingSummary?,
          Stream<BorrowingSummary?>
        >
    with
        $FutureModifier<BorrowingSummary?>,
        $StreamProvider<BorrowingSummary?> {
  BorrowingSummaryProvider._({
    required BorrowingSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'borrowingSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$borrowingSummaryHash();

  @override
  String toString() {
    return r'borrowingSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<BorrowingSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<BorrowingSummary?> create(Ref ref) {
    final argument = this.argument as String;
    return borrowingSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BorrowingSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$borrowingSummaryHash() => r'99e526828eb91c2530f51f2b2f9d19334a4dfa8f';

final class BorrowingSummaryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<BorrowingSummary?>, String> {
  BorrowingSummaryFamily._()
    : super(
        retry: null,
        name: r'borrowingSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BorrowingSummaryProvider call(String id) =>
      BorrowingSummaryProvider._(argument: id, from: this);

  @override
  String toString() => r'borrowingSummaryProvider';
}

/// Lifetime roll-up derived from the summaries stream — drives the hero.

@ProviderFor(lifetimeStats)
final lifetimeStatsProvider = LifetimeStatsProvider._();

/// Lifetime roll-up derived from the summaries stream — drives the hero.

final class LifetimeStatsProvider
    extends $FunctionalProvider<LifetimeStats, LifetimeStats, LifetimeStats>
    with $Provider<LifetimeStats> {
  /// Lifetime roll-up derived from the summaries stream — drives the hero.
  LifetimeStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lifetimeStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lifetimeStatsHash();

  @$internal
  @override
  $ProviderElement<LifetimeStats> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LifetimeStats create(Ref ref) {
    return lifetimeStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LifetimeStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LifetimeStats>(value),
    );
  }
}

String _$lifetimeStatsHash() => r'4d1dab9fb0b926e710151b9b8a3027ac14dfd267';
