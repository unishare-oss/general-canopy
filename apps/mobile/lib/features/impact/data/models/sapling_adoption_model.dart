import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:canopy/features/impact/domain/entities/sapling_streak.dart';

class SaplingAdoptionModel {
  const SaplingAdoptionModel({
    required this.saplingId,
    required this.nickname,
    required this.streakDays,
    required this.lastCheckIn,
    required this.adoptedAt,
    required this.wateringIntervalDays,
  });

  final String saplingId;
  final String nickname;
  final int streakDays;
  final DateTime? lastCheckIn;
  final DateTime adoptedAt;
  final int wateringIntervalDays;

  factory SaplingAdoptionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return SaplingAdoptionModel(
      saplingId: data['saplingId'] as String? ?? doc.id,
      nickname: data['nickname'] as String? ?? 'My sapling',
      streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
      lastCheckIn: (data['lastCheckIn'] as Timestamp?)?.toDate(),
      adoptedAt: (data['adoptedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wateringIntervalDays:
          (data['wateringIntervalDays'] as num?)?.toInt() ?? 7,
    );
  }

  SaplingStreak toEntity() {
    final isActive =
        lastCheckIn != null &&
        DateTime.now().difference(lastCheckIn!).inDays <=
            wateringIntervalDays + 1;
    return SaplingStreak(
      saplingId: saplingId,
      nickname: nickname,
      streakDays: streakDays,
      lastCheckIn: lastCheckIn,
      isActive: isActive,
    );
  }
}
