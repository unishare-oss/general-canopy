import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<({Uint8List? bytes, String? name})> pickPhoto() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );
  if (file == null) return (bytes: null, name: null);
  final bytes = await file.readAsBytes();
  return (bytes: bytes, name: file.name);
}
