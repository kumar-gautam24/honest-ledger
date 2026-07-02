// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The unified home feed: every borrowing and recurring item as one list of
/// [ObligationView]s, sorted by urgency (overdue and soonest-due first). The
/// filter is applied in the UI so the sorted list is computed once.

@ProviderFor(homeFeed)
final homeFeedProvider = HomeFeedProvider._();

/// The unified home feed: every borrowing and recurring item as one list of
/// [ObligationView]s, sorted by urgency (overdue and soonest-due first). The
/// filter is applied in the UI so the sorted list is computed once.

final class HomeFeedProvider
    extends
        $FunctionalProvider<
          List<ObligationView>,
          List<ObligationView>,
          List<ObligationView>
        >
    with $Provider<List<ObligationView>> {
  /// The unified home feed: every borrowing and recurring item as one list of
  /// [ObligationView]s, sorted by urgency (overdue and soonest-due first). The
  /// filter is applied in the UI so the sorted list is computed once.
  HomeFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeFeedHash();

  @$internal
  @override
  $ProviderElement<List<ObligationView>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ObligationView> create(Ref ref) {
    return homeFeed(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ObligationView> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ObligationView>>(value),
    );
  }
}

String _$homeFeedHash() => r'8c76ea4e69b78ad3a4beabbd1ef41ba0bf3a43e6';

/// True while either underlying stream has yet to deliver its first value.

@ProviderFor(homeFeedLoading)
final homeFeedLoadingProvider = HomeFeedLoadingProvider._();

/// True while either underlying stream has yet to deliver its first value.

final class HomeFeedLoadingProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// True while either underlying stream has yet to deliver its first value.
  HomeFeedLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeFeedLoadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeFeedLoadingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return homeFeedLoading(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$homeFeedLoadingHash() => r'80171c09340072e5d464285e1ed0256fa03528d9';

/// The true committed monthly outgo — EMIs + loan plans + recurring — split by
/// kind. Drives the home "PER MONTH" statement line.

@ProviderFor(monthlyObligationStats)
final monthlyObligationStatsProvider = MonthlyObligationStatsProvider._();

/// The true committed monthly outgo — EMIs + loan plans + recurring — split by
/// kind. Drives the home "PER MONTH" statement line.

final class MonthlyObligationStatsProvider
    extends
        $FunctionalProvider<
          MonthlyObligationStats,
          MonthlyObligationStats,
          MonthlyObligationStats
        >
    with $Provider<MonthlyObligationStats> {
  /// The true committed monthly outgo — EMIs + loan plans + recurring — split by
  /// kind. Drives the home "PER MONTH" statement line.
  MonthlyObligationStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyObligationStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyObligationStatsHash();

  @$internal
  @override
  $ProviderElement<MonthlyObligationStats> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MonthlyObligationStats create(Ref ref) {
    return monthlyObligationStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonthlyObligationStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthlyObligationStats>(value),
    );
  }
}

String _$monthlyObligationStatsHash() =>
    r'2b5f349fc691d79afda891d909ff0b64899ee651';

/// The current calendar month as a statement: due, paid, remaining.

@ProviderFor(monthPlan)
final monthPlanProvider = MonthPlanProvider._();

/// The current calendar month as a statement: due, paid, remaining.

final class MonthPlanProvider
    extends $FunctionalProvider<MonthPlan, MonthPlan, MonthPlan>
    with $Provider<MonthPlan> {
  /// The current calendar month as a statement: due, paid, remaining.
  MonthPlanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthPlanProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthPlanHash();

  @$internal
  @override
  $ProviderElement<MonthPlan> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MonthPlan create(Ref ref) {
    return monthPlan(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonthPlan value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthPlan>(value),
    );
  }
}

String _$monthPlanHash() => r'fae16a67784dc146cac34b726eb204f1c393d47d';

/// Per-lender waste ranking for the Leak statement, worst first.

@ProviderFor(lenderWaste)
final lenderWasteProvider = LenderWasteProvider._();

/// Per-lender waste ranking for the Leak statement, worst first.

final class LenderWasteProvider
    extends
        $FunctionalProvider<
          List<LenderWaste>,
          List<LenderWaste>,
          List<LenderWaste>
        >
    with $Provider<List<LenderWaste>> {
  /// Per-lender waste ranking for the Leak statement, worst first.
  LenderWasteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lenderWasteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lenderWasteHash();

  @$internal
  @override
  $ProviderElement<List<LenderWaste>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<LenderWaste> create(Ref ref) {
    return lenderWaste(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LenderWaste> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LenderWaste>>(value),
    );
  }
}

String _$lenderWasteHash() => r'1c9f1fa1f1a6c6b7df3c73a913acc6ebe7ff53e2';

/// Month-by-month outflow over the coming year, with freed-up moments.

@ProviderFor(outflowProjection)
final outflowProjectionProvider = OutflowProjectionProvider._();

/// Month-by-month outflow over the coming year, with freed-up moments.

final class OutflowProjectionProvider
    extends
        $FunctionalProvider<
          OutflowProjection,
          OutflowProjection,
          OutflowProjection
        >
    with $Provider<OutflowProjection> {
  /// Month-by-month outflow over the coming year, with freed-up moments.
  OutflowProjectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outflowProjectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outflowProjectionHash();

  @$internal
  @override
  $ProviderElement<OutflowProjection> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OutflowProjection create(Ref ref) {
    return outflowProjection(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OutflowProjection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OutflowProjection>(value),
    );
  }
}

String _$outflowProjectionHash() => r'ef482d823d2f2cf3c4eb58f95300b812ad7ae2ed';
