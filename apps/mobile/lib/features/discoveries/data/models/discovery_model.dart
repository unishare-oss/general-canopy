import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:canopy/features/discoveries/domain/entities/discovery.dart';

part 'discovery_model.freezed.dart';
part 'discovery_model.g.dart';

DateTime _timestampToDateTime(dynamic v) =>
    v is Timestamp ? v.toDate() : DateTime.parse(v as String);

@freezed
abstract class DiscoveryModel with _$DiscoveryModel {
  const DiscoveryModel._();

  const factory DiscoveryModel({
    required String title,
    required String description,
    required String category,
    required double lat,
    required double lng,
    required String neighborhood,
    @JsonKey(name: 'colorHex') required String colorHex,
    @JsonKey(fromJson: _timestampToDateTime) required DateTime createdAt,
    required String createdBy,
    String? photoUrl,
  }) = _DiscoveryModel;

  factory DiscoveryModel.fromJson(Map<String, dynamic> json) =>
      _$DiscoveryModelFromJson(json);

  factory DiscoveryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) => DiscoveryModel.fromJson(doc.data()!);

  Discovery toEntity(String id) => Discovery(
    id: id,
    title: title,
    description: description,
    category: category,
    lat: lat,
    lng: lng,
    neighborhood: neighborhood,
    colorHex: colorHex,
    createdAt: createdAt,
    createdBy: createdBy,
    photoUrl: photoUrl,
  );
}
