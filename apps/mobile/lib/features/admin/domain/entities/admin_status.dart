class AdminStatus {
  const AdminStatus({required this.userId, required this.isAdmin});

  final String userId;
  final bool isAdmin;

  static const AdminStatus notAdmin = AdminStatus(userId: '', isAdmin: false);
}
