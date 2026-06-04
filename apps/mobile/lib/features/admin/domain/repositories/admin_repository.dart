abstract interface class AdminRepository {
  Future<bool> checkAdminStatus(String uid);
  Future<void> grantAdmin(String targetUid);
}
