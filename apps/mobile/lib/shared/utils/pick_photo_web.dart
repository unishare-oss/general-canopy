import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

Future<({Uint8List? bytes, String? name})> pickPhoto() async {
  final completer = Completer<({Uint8List? bytes, String? name})>();

  final input = html.FileUploadInputElement()..accept = 'image/*';
  html.document.body?.append(input);
  input.click();

  input.onChange.listen((_) {
    final file = input.files?.first;
    input.remove();
    if (file == null) {
      completer.complete((bytes: null, name: null));
      return;
    }
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((_) {
      completer.complete((
        bytes: reader.result as Uint8List?,
        name: file.name,
      ));
    });
  });

  return completer.future;
}
