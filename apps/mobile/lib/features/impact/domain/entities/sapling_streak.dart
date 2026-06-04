class SaplingStreak {
  const SaplingStreak({
    required this.saplingId,
    required this.nickname,
    required this.streakDays,
    required this.lastCheckIn,
    required this.isActive,
  });

  final String saplingId;
  final String nickname;
  final int streakDays;
  final DateTime? lastCheckIn;

  /// Computed in the repository mapper; not stored in Firestore.
  final bool isActive;
}
