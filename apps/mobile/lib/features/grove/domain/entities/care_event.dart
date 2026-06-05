enum CareEventType { adopted, water, fertilize, prune, inspect }

class CareEvent {
  const CareEvent({
    required this.id,
    required this.type,
    required this.performedAt,
    this.note,
    this.healthScoreDelta,
    this.photoUrl,
  });

  final String id;
  final CareEventType type;
  final DateTime performedAt;
  final String? note;
  final int? healthScoreDelta;
  final String? photoUrl;
}
