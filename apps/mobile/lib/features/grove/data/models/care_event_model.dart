import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:canopy/core/converters/timestamp_converter.dart';
import 'package:canopy/features/grove/domain/entities/care_event.dart';

part 'care_event_model.freezed.dart';
part 'care_event_model.g.dart';

@freezed
abstract class CareEventModel with _$CareEventModel {
  const CareEventModel._();

  const factory CareEventModel({
    @Default('water') String type,
    @TimestampConverter() required DateTime performedAt,
    String? note,
    int? healthScoreDelta,
    String? photoUrl,
  }) = _CareEventModel;

  factory CareEventModel.fromJson(Map<String, dynamic> json) =>
      _$CareEventModelFromJson(json);

  CareEvent toEntity(String id) => CareEvent(
    id: id,
    type: _parseCareEventType(type),
    performedAt: performedAt,
    note: note,
    healthScoreDelta: healthScoreDelta,
    photoUrl: photoUrl,
  );
}

CareEventType _parseCareEventType(String s) => switch (s) {
  'water' => CareEventType.water,
  'fertilize' => CareEventType.fertilize,
  'prune' => CareEventType.prune,
  'inspect' => CareEventType.inspect,
  _ => CareEventType.adopted,
};
