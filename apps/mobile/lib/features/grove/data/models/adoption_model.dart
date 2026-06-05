import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:canopy/core/converters/timestamp_converter.dart';
import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';

part 'adoption_model.freezed.dart';
part 'adoption_model.g.dart';

@freezed
abstract class AdoptionModel with _$AdoptionModel {
  const AdoptionModel._();

  const factory AdoptionModel({
    required String saplingId,
    required String nickname,
    required String species,
    @Default('') String street,
    required String neighborhood,
    required String colorHex,
    String? photoUrl,
    String? coverPhotoUrl,
    @TimestampConverter() required DateTime adoptedAt,
    @Default(80) int healthScore,
    @TimestampConverter() required DateTime nextActionAt,
    @Default('water') String nextActionType,
  }) = _AdoptionModel;

  factory AdoptionModel.fromJson(Map<String, dynamic> json) =>
      _$AdoptionModelFromJson(json);

  AdoptedSapling toEntity(String id) => AdoptedSapling(
    id: id,
    saplingId: saplingId,
    nickname: nickname,
    species: species,
    street: street,
    neighborhood: neighborhood,
    colorHex: colorHex,
    adoptedAt: adoptedAt,
    healthScore: healthScore,
    nextActionAt: nextActionAt,
    nextActionType: _parseActionType(nextActionType),
    photoUrl: photoUrl,
    coverPhotoUrl: coverPhotoUrl,
  );
}

NextActionType _parseActionType(String s) => switch (s) {
  'fertilize' => NextActionType.fertilize,
  'prune' => NextActionType.prune,
  'inspect' => NextActionType.inspect,
  _ => NextActionType.water,
};
