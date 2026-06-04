import 'package:canopy/features/impact/domain/entities/activity_type.dart';

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.saplingNickname,
  });

  final String id;
  final ActivityType type;
  final String description;
  final DateTime timestamp;
  final String? saplingNickname;
}
