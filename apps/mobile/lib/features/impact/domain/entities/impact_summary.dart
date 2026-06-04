class ImpactSummary {
  const ImpactSummary({
    required this.co2OffsetKg,
    required this.waterGivenLiters,
    required this.totalSurvivalDays,
    required this.adoptedCount,
    required this.lastUpdated,
  });

  final double co2OffsetKg;
  final double waterGivenLiters;
  final int totalSurvivalDays;
  final int adoptedCount;
  final DateTime lastUpdated;

  factory ImpactSummary.zero() => ImpactSummary(
    co2OffsetKg: 0,
    waterGivenLiters: 0,
    totalSurvivalDays: 0,
    adoptedCount: 0,
    lastUpdated: DateTime.fromMillisecondsSinceEpoch(0),
  );
}
