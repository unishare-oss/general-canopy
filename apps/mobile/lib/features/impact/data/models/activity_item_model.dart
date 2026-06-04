import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:canopy/features/impact/domain/entities/activity_item.dart';
import 'package:canopy/features/impact/domain/entities/activity_type.dart';

class ActivityItemModel {
  const ActivityItemModel({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.saplingNickname,
  });

  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final String? saplingNickname;

  factory ActivityItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ActivityItemModel(
      id: data['id'] as String? ?? doc.id,
      type: data['type'] as String? ?? 'adopted',
      description: data['description'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      saplingNickname: data['saplingNickname'] as String?,
    );
  }

  ActivityItem toEntity() => ActivityItem(
    id: id,
    type: ActivityType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ActivityType.adopted,
    ),
    description: description,
    timestamp: timestamp,
    saplingNickname: saplingNickname,
  );
}
