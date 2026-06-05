import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:canopy/features/impact/domain/entities/impact_summary.dart';

class ImpactSummaryModel {
  const ImpactSummaryModel({
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

  factory ImpactSummaryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ImpactSummaryModel(
      co2OffsetKg: (data['co2OffsetKg'] as num?)?.toDouble() ?? 0,
      waterGivenLiters: (data['waterGivenLiters'] as num?)?.toDouble() ?? 0,
      totalSurvivalDays: (data['totalSurvivalDays'] as num?)?.toInt() ?? 0,
      adoptedCount: (data['adoptedCount'] as num?)?.toInt() ?? 0,
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  ImpactSummary toEntity() => ImpactSummary(
    co2OffsetKg: co2OffsetKg,
    waterGivenLiters: waterGivenLiters,
    totalSurvivalDays: totalSurvivalDays,
    adoptedCount: adoptedCount,
    lastUpdated: lastUpdated,
  );
}
