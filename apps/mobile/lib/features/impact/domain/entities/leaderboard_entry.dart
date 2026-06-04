class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.neighborhood,
    required this.co2OffsetKg,
    required this.rank,
  });

  final String userId;
  final String displayName;
  final String neighborhood;
  final double co2OffsetKg;
  final int rank;
}
