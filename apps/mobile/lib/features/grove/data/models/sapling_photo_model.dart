import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:canopy/core/converters/timestamp_converter.dart';
import 'package:canopy/features/grove/domain/entities/sapling_photo.dart';

part 'sapling_photo_model.freezed.dart';
part 'sapling_photo_model.g.dart';

@freezed
abstract class SaplingPhotoModel with _$SaplingPhotoModel {
  const SaplingPhotoModel._();

  const factory SaplingPhotoModel({
    required String url,
    @TimestampConverter() required DateTime takenAt,
    String? note,
  }) = _SaplingPhotoModel;

  factory SaplingPhotoModel.fromJson(Map<String, dynamic> json) =>
      _$SaplingPhotoModelFromJson(json);

  SaplingPhoto toEntity(String id) =>
      SaplingPhoto(id: id, url: url, takenAt: takenAt, note: note);
}
