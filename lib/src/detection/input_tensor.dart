import 'package:flutter_on_device_ml/src/detection/detection_exception.dart';
import 'package:flutter_on_device_ml/src/imaging/pixel_image.dart';

/// Builds an NHWC input list for a uint8 or float32 image tensor.
///
/// [shape] is `[1, height, width, 3]` or `[height, width, 3]`. Float inputs
/// are `(channel - mean) / std`. Uint8 inputs stay in 0..255.
Object buildInputTensor({
  required PixelImage image,
  required List<int> shape,
  required bool floating,
  required double mean,
  required double std,
}) {
  if (std == 0) {
    throw const DetectionException('floatStd must not be 0.');
  }
  late final int height;
  late final int width;
  late final bool hasBatch;
  if (shape.length == 4 && shape[0] == 1 && shape[3] == 3) {
    hasBatch = true;
    height = shape[1];
    width = shape[2];
  } else if (shape.length == 3 && shape[2] == 3) {
    hasBatch = false;
    height = shape[0];
    width = shape[1];
  } else {
    throw DetectionException(
      'Unsupported input shape $shape. Expected NHWC with 3 channels.',
    );
  }
  if (image.width != width || image.height != height) {
    throw DetectionException(
      'Prepared image is ${image.width}x${image.height}; the model expects ${width}x$height.',
    );
  }

  List<num> pixel(int x, int y) {
    final offset = (y * width + x) * 4;
    final red = image.rgba[offset];
    final green = image.rgba[offset + 1];
    final blue = image.rgba[offset + 2];
    if (!floating) return [red, green, blue];
    return [(red - mean) / std, (green - mean) / std, (blue - mean) / std];
  }

  final plane = List<List<List<num>>>.generate(
    height,
    (y) => List<List<num>>.generate(
      width,
      (x) => pixel(x, y),
      growable: false,
    ),
    growable: false,
  );
  if (hasBatch) return [plane];
  return plane;
}
