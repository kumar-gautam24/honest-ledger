// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cardRepository)
final cardRepositoryProvider = CardRepositoryProvider._();

final class CardRepositoryProvider
    extends $FunctionalProvider<CardRepository, CardRepository, CardRepository>
    with $Provider<CardRepository> {
  CardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardRepositoryHash();

  @$internal
  @override
  $ProviderElement<CardRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CardRepository create(Ref ref) {
    return cardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardRepository>(value),
    );
  }
}

String _$cardRepositoryHash() => r'6f3adcefa275b6271509553efa381b3e70188de2';

/// All cards, active first.

@ProviderFor(cards)
final cardsProvider = CardsProvider._();

/// All cards, active first.

final class CardsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CardAccount>>,
          List<CardAccount>,
          Stream<List<CardAccount>>
        >
    with
        $FutureModifier<List<CardAccount>>,
        $StreamProvider<List<CardAccount>> {
  /// All cards, active first.
  CardsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardsHash();

  @$internal
  @override
  $StreamProviderElement<List<CardAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CardAccount>> create(Ref ref) {
    return cards(ref);
  }
}

String _$cardsHash() => r'2142dd27bbfddbe671962847236d72582278db29';

/// A single card's statements, newest cycle first.

@ProviderFor(cardStatements)
final cardStatementsProvider = CardStatementsFamily._();

/// A single card's statements, newest cycle first.

final class CardStatementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CardStatement>>,
          List<CardStatement>,
          Stream<List<CardStatement>>
        >
    with
        $FutureModifier<List<CardStatement>>,
        $StreamProvider<List<CardStatement>> {
  /// A single card's statements, newest cycle first.
  CardStatementsProvider._({
    required CardStatementsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cardStatementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardStatementsHash();

  @override
  String toString() {
    return r'cardStatementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<CardStatement>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CardStatement>> create(Ref ref) {
    final argument = this.argument as String;
    return cardStatements(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CardStatementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardStatementsHash() => r'efa8d892f194e94e2a4fdb5f20ef1405f3d97ebd';

/// A single card's statements, newest cycle first.

final class CardStatementsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<CardStatement>>, String> {
  CardStatementsFamily._()
    : super(
        retry: null,
        name: r'cardStatementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A single card's statements, newest cycle first.

  CardStatementsProvider call(String cardId) =>
      CardStatementsProvider._(argument: cardId, from: this);

  @override
  String toString() => r'cardStatementsProvider';
}

/// Every statement across cards — for the month plan fold-in.

@ProviderFor(allCardStatements)
final allCardStatementsProvider = AllCardStatementsProvider._();

/// Every statement across cards — for the month plan fold-in.

final class AllCardStatementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CardStatement>>,
          List<CardStatement>,
          Stream<List<CardStatement>>
        >
    with
        $FutureModifier<List<CardStatement>>,
        $StreamProvider<List<CardStatement>> {
  /// Every statement across cards — for the month plan fold-in.
  AllCardStatementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allCardStatementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allCardStatementsHash();

  @$internal
  @override
  $StreamProviderElement<List<CardStatement>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CardStatement>> create(Ref ref) {
    return allCardStatements(ref);
  }
}

String _$allCardStatementsHash() => r'6ff1df7c482d4e9376c43d69aa88ce127797867e';
