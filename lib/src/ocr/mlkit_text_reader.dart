import 'dart:async';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:flutter_on_device_ml/src/imaging/image_gateway.dart';
import 'package:flutter_on_device_ml/src/ocr/text_read.dart';
import 'package:flutter_on_device_ml/src/ocr/text_reader.dart';

/// Latin text recognition through ML Kit. The plugin bundles the Latin model.
class MlkitTextReader implements TextReader {
  TextRecognizer? _recognizer;

  @override
  Future<TextRead> read(PickedPhoto photo) async {
    final path = photo.path;
    if (path == null) {
      throw const FormatException(
        'Text recognition needs the image file from the camera or gallery.',
      );
    }
    final result = await _engine().processImage(InputImage.fromFilePath(path));
    final regions = <TextRegion>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        final box = line.boundingBox;
        regions.add(
          TextRegion(
            text: line.text,
            left: box.left,
            top: box.top,
            right: box.right,
            bottom: box.bottom,
          ),
        );
      }
    }
    return TextRead(text: result.text, regions: regions);
  }

  @override
  void close() {
    final engine = _recognizer;
    _recognizer = null;
    if (engine != null) unawaited(engine.close());
  }

  TextRecognizer _engine() {
    return _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
  }
}
