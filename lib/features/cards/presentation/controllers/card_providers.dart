import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/card_account.dart';
import '../../domain/entities/card_statement.dart';
import '../../domain/repositories/card_repository.dart';

part 'card_providers.g.dart';

@riverpod
CardRepository cardRepository(Ref ref) => sl<CardRepository>();

/// All cards, active first.
@riverpod
Stream<List<CardAccount>> cards(Ref ref) =>
    ref.watch(cardRepositoryProvider).watchCards();

/// A single card's statements, newest cycle first.
@riverpod
Stream<List<CardStatement>> cardStatements(Ref ref, String cardId) =>
    ref.watch(cardRepositoryProvider).watchStatements(cardId);

/// Every statement across cards — for the month plan fold-in.
@riverpod
Stream<List<CardStatement>> allCardStatements(Ref ref) =>
    ref.watch(cardRepositoryProvider).watchAllStatements();
