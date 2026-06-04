import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:canopy/features/impact/domain/entities/achievement.dart';

class AchievementModel {
  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.earnedAt,
  });

  final String id;
  final String title;
  final String description;
  final String iconName;
  final DateTime earnedAt;

  factory AchievementModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AchievementModel(
      id: data['id'] as String? ?? doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      iconName: data['iconName'] as String? ?? '',
      earnedAt: (data['earnedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Achievement toEntity() => Achievement(
    id: id,
    title: title,
    description: description,
    iconName: iconName,
    earnedAt: earnedAt,
  );
}
