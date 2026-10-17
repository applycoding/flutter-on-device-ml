import 'package:flutter_on_device_ml/src/imaging/image_gateway.dart';
import 'package:flutter_on_device_ml/src/ocr/text_read.dart';

/// On-device text recognition. Tests supply a fake.
abstract class TextReader {
  Future<TextRead> read(PickedPhoto photo);

  void close();
}
