import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:canopy/features/saplings/data/datasources/firestore_sapling_datasource.dart';
import 'package:canopy/features/saplings/data/repositories/sapling_repository_impl.dart';
import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';

part 'sapling_repository_provider.g.dart';

@riverpod
SaplingRepository saplingRepository(Ref ref) => SaplingRepositoryImpl(
  FirestoreSaplingDatasourceImpl(FirebaseFirestore.instance),
);
