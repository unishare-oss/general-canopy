import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:canopy/features/impact/domain/entities/leaderboard_entry.dart';

class LeaderboardEntryModel {
  const LeaderboardEntryModel({
    required this.userId,
    required this.displayName,
    required this.neighborhood,
    required this.co2OffsetKg,
  });

  final String userId;
  final String displayName;
  final String neighborhood;
  final double co2OffsetKg;

  factory LeaderboardEntryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return LeaderboardEntryModel(
      userId: data['userId'] as String? ?? doc.id,
      displayName: data['displayName'] as String? ?? 'Anonymous',
      neighborhood: data['neighborhood'] as String? ?? '',
      co2OffsetKg: (data['co2OffsetKg'] as num?)?.toDouble() ?? 0,
    );
  }

  LeaderboardEntry toEntity(int rank) => LeaderboardEntry(
    userId: userId,
    displayName: displayName,
    neighborhood: neighborhood,
    co2OffsetKg: co2OffsetKg,
    rank: rank,
  );
}
