import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:canopy/features/discoveries/data/datasources/firestore_discovery_datasource.dart';
import 'package:canopy/features/discoveries/data/repositories/discovery_repository_impl.dart';
import 'package:canopy/features/discoveries/domain/repositories/discovery_repository.dart';

part 'discovery_repository_provider.g.dart';

@riverpod
DiscoveryRepository discoveryRepository(Ref ref) => DiscoveryRepositoryImpl(
  FirestoreDiscoveryDatasourceImpl(FirebaseFirestore.instance),
);
