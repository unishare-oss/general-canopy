import 'package:canopy/features/admin/data/datasources/firestore_admin_datasource.dart';
import 'package:canopy/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._datasource);

  final FirestoreAdminDatasource _datasource;

  @override
  Future<bool> checkAdminStatus(String uid) => _datasource.isAdmin(uid);

  @override
  Future<void> grantAdmin(String targetUid) =>
      _datasource.createAdminDocument(targetUid);
}
