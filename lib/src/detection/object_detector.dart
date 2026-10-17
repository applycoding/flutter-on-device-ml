import 'package:flutter_on_device_ml/src/detection/detection_box.dart';
import 'package:flutter_on_device_ml/src/imaging/pixel_image.dart';

/// On-device object detector. Tests supply a fake. The app uses TensorFlow Lite.
abstract class ObjectDetector {
  String get name;

  /// True when a `.tflite` file is available to open.
  Future<bool> isModelReady();

  /// Returns boxes in [image] pixel coordinates.
  Future<List<DetectionBox>> detect(PixelImage image);

  void close();
}
