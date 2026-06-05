import 'dart:convert';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'avatar_picker.g.dart';

/// Opens the platform image picker and returns the chosen image as a
/// base64-encoded 256px square JPEG, or null when the user cancels.
///
/// Avatars are stored inline in the Firestore user doc (the team project has
/// no Firebase Storage bucket — Blaze plan required); 256px JPEG at quality
/// 80 is ~20-40 KB, far below the 1 MiB document limit and the 128 KiB
/// security-rule cap.
class AvatarPicker {
  AvatarPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const int _targetSize = 256;
  static const int _jpegQuality = 80;

  Future<String?> pickAndEncode() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      // Pre-shrink on platforms that support it; full compression below.
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final square = img.copyResizeCropSquare(decoded, size: _targetSize);
    final jpeg = img.encodeJpg(square, quality: _jpegQuality);
    return base64Encode(jpeg);
  }
}

@Riverpod(keepAlive: true)
AvatarPicker avatarPicker(Ref ref) => AvatarPicker();
