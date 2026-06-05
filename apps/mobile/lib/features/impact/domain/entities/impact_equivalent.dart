class ImpactEquivalent {
  const ImpactEquivalent({
    required this.label,
    required this.value,
    required this.unit,
    required this.iconName,
    this.subtitle,
  });

  final String label;
  final double value;
  final String unit;
  final String iconName;
  final String? subtitle;
}
