import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/usecases/get_available_saplings.dart';
import 'package:canopy/features/saplings/presentation/providers/sapling_repository_provider.dart';

part 'available_saplings_provider.g.dart';

@riverpod
Stream<List<Sapling>> availableSaplings(Ref ref) =>
    GetAvailableSaplings(ref.watch(saplingRepositoryProvider))();

@riverpod
Stream<List<Sapling>> allSaplings(Ref ref) =>
    ref.watch(saplingRepositoryProvider).getAllSaplings();
