import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:canopy/features/admin/data/datasources/firestore_admin_datasource.dart';
import 'package:canopy/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:canopy/features/admin/domain/repositories/admin_repository.dart';

part 'admin_repository_provider.g.dart';

@riverpod
AdminRepository adminRepository(Ref ref) => AdminRepositoryImpl(
  FirestoreAdminDatasourceImpl(FirebaseFirestore.instance),
);
