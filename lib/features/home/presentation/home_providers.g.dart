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
