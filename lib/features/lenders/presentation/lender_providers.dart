import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/injector.dart';
import '../domain/entities/lender.dart';
import '../domain/repositories/lender_repository.dart';

part 'lender_providers.g.dart';

@riverpod
LenderRepository lenderRepository(Ref ref) => sl<LenderRepository>();

@riverpod
Stream<List<Lender>> allLenders(Ref ref) =>
    ref.watch(lenderRepositoryProvider).watchAll();
