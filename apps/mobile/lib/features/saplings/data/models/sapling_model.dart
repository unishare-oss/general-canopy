import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';

part 'sapling_model.freezed.dart';
part 'sapling_model.g.dart';

@freezed
abstract class SaplingModel with _$SaplingModel {
  const SaplingModel._();

  const factory SaplingModel({
    required String nickname,
    required String species,
    required String latin,
    required String personality,
    String? photoUrl,
    @JsonKey(name: 'color') required String colorHex,
    required String street,
    required String neighborhood,
    required double lat,
    required double lng,
    required String ageLabel,
    required String heightLabel,
    required String waterNeedLabel,
    required String lightLabel,
    @Default(3) int wateringIntervalDays,
    @Default('available') String status,
    String? adoptedBy,
  }) = _SaplingModel;

  factory SaplingModel.fromJson(Map<String, dynamic> json) =>
      _$SaplingModelFromJson(json);

  Sapling toEntity(String id) => Sapling(
    id: id,
    nickname: nickname,
    species: species,
    latin: latin,
    personality: personality,
    street: street,
    neighborhood: neighborhood,
    lat: lat,
    lng: lng,
    ageLabel: ageLabel,
    heightLabel: heightLabel,
    waterNeedLabel: waterNeedLabel,
    lightLabel: lightLabel,
    wateringIntervalDays: wateringIntervalDays,
    colorHex: colorHex,
    // Unknown/new status strings fall back to `available` on purpose — a
    // malformed value should never make a tree look adopted/unavailable.
    status: switch (status) {
      'adopted' => SaplingStatus.adopted,
      _ => SaplingStatus.available,
    },
    photoUrl: photoUrl,
    adoptedBy: adoptedBy,
  );
}
