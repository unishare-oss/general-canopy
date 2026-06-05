class Achievement {
  const Achievement({
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
}
