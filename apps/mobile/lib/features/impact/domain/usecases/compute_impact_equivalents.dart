import 'package:canopy/features/impact/domain/constants/impact_constants.dart';
import 'package:canopy/features/impact/domain/entities/impact_equivalent.dart';
import 'package:canopy/features/impact/domain/entities/impact_summary.dart';

class ComputeImpactEquivalents {
  const ComputeImpactEquivalents();

  List<ImpactEquivalent> call(ImpactSummary summary) => [
    ImpactEquivalent(
      label: 'Car miles offset',
      value: summary.co2OffsetKg / ImpactConstants.kCo2KgPerCarMile,
      unit: 'mi',
      iconName: 'car',
    ),
    ImpactEquivalent(
      label: 'Coast-to-coast flight',
      value: (summary.co2OffsetKg / ImpactConstants.kCo2KgCoastToCoast) * 100,
      unit: '%',
      iconName: 'flight',
    ),
    ImpactEquivalent(
      label: 'Birds welcomed home',
      value: summary.adoptedCount * ImpactConstants.kBirdsPerTree,
      unit: '~',
      iconName: 'birds',
      subtitle: 'Est. nesting & feeding',
    ),
  ];
}
