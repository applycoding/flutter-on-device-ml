import 'dart:math' as math;

import 'package:flutter_on_device_ml/src/detection/detection_box.dart';
import 'package:flutter_on_device_ml/src/detection/model_config.dart';
import 'package:flutter_on_device_ml/src/imaging/pixel_image.dart';

/// Maps a model input canvas back to the source image.
///
/// [contentWidth] and [contentHeight] are the resized image inside the
/// destination. Padding sits outside that rectangle. For a stretch fit the
/// content is the whole destination and both pads are zero.
class ImageTransform {
  const ImageTransform({
    required this.srcWidth,
    required this.srcHeight,
    required this.dstWidth,
    required this.dstHeight,
    required this.padLeft,
    required this.padTop,
    required this.contentWidth,
    required this.contentHeight,
    required this.letterbox,
  });

  final int srcWidth;
  final int srcHeight;
  final int dstWidth;
  final int dstHeight;
  final int padLeft;
  final int padTop;
  final int contentWidth;
  final int contentHeight;
  final bool letterbox;

  int get padRight => dstWidth - padLeft - contentWidth;
  int get padBottom => dstHeight - padTop - contentHeight;

  double mapXToSource(double modelX) =>
      (modelX - padLeft) * srcWidth / contentWidth;

  double mapYToSource(double modelY) =>
      (modelY - padTop) * srcHeight / contentHeight;
}

class FittedImage {
  const FittedImage({required this.image, required this.transform});

  final PixelImage image;
  final ImageTransform transform;
}

/// Axis-aligned rectangle in source pixels. The right and bottom edges may
/// sit on the image boundary.
class SourceRect {
  const SourceRect(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double right;
  final double bottom;

  bool get isEmpty => right <= left || bottom <= top;
}

/// Rectangle in a widget's coordinate space.
class CanvasRect {
  const CanvasRect(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double right;
  final double bottom;
}

ImageTransform computeTransform({
  required int srcWidth,
  required int srcHeight,
  required int dstWidth,
  required int dstHeight,
  required bool letterbox,
}) {
  if (srcWidth <= 0 || srcHeight <= 0 || dstWidth <= 0 || dstHeight <= 0) {
    throw ArgumentError('Image dimensions must be positive.');
  }
  if (!letterbox) {
    return ImageTransform(
      srcWidth: srcWidth,
      srcHeight: srcHeight,
      dstWidth: dstWidth,
      dstHeight: dstHeight,
      padLeft: 0,
      padTop: 0,
      contentWidth: dstWidth,
      contentHeight: dstHeight,
      letterbox: false,
    );
  }
  final scale = math.min(dstWidth / srcWidth, dstHeight / srcHeight);
  var contentWidth = (srcWidth * scale).round();
  var contentHeight = (srcHeight * scale).round();
  if (contentWidth > dstWidth) contentWidth = dstWidth;
  if (contentHeight > dstHeight) contentHeight = dstHeight;
  if (contentWidth < 1) contentWidth = 1;
  if (contentHeight < 1) contentHeight = 1;
  final padX = dstWidth - contentWidth;
  final padY = dstHeight - contentHeight;
  return ImageTransform(
    srcWidth: srcWidth,
    srcHeight: srcHeight,
    dstWidth: dstWidth,
    dstHeight: dstHeight,
    padLeft: padX ~/ 2,
    padTop: padY ~/ 2,
    contentWidth: contentWidth,
    contentHeight: contentHeight,
    letterbox: true,
  );
}

/// Resizes [source] into [dstWidth] x [dstHeight].
///
/// Letterbox keeps the aspect ratio and fills the bars with [pad]. Stretch
/// fills the destination. Sampling is nearest-neighbor with integer division
/// so the mapping is deterministic.
FittedImage fitImage(
  PixelImage source, {
  required int dstWidth,
  required int dstHeight,
  required bool letterbox,
  int padR = 0,
  int padG = 0,
  int padB = 0,
  int padA = 255,
}) {
  final transform = computeTransform(
    srcWidth: source.width,
    srcHeight: source.height,
    dstWidth: dstWidth,
    dstHeight: dstHeight,
    letterbox: letterbox,
  );
  final out = PixelImage.filled(
    dstWidth,
    dstHeight,
    r: padR,
    g: padG,
    b: padB,
    a: padA,
  );
  for (var y = 0; y < transform.contentHeight; y++) {
    final srcY = _sourceIndex(y, source.height, transform.contentHeight);
    for (var x = 0; x < transform.contentWidth; x++) {
      final srcX = _sourceIndex(x, source.width, transform.contentWidth);
      out.setPixel(
        transform.padLeft + x,
        transform.padTop + y,
        source.red(srcX, srcY),
        source.green(srcX, srcY),
        source.blue(srcX, srcY),
        source.alpha(srcX, srcY),
      );
    }
  }
  return FittedImage(image: out, transform: transform);
}

int _sourceIndex(int contentIndex, int srcSize, int contentSize) {
  final index = contentIndex * srcSize ~/ contentSize;
  if (index < 0) return 0;
  if (index >= srcSize) return srcSize - 1;
  return index;
}

/// Maps one model box into source pixels and clamps it to the image.
SourceRect mapModelBoxToSource({
  required double first,
  required double second,
  required double third,
  required double fourth,
  required ImageTransform transform,
  required bool normalized,
  required BoxOrder order,
}) {
  late final double xmin;
  late final double ymin;
  late final double xmax;
  late final double ymax;
  switch (order) {
    case BoxOrder.yxyx:
      ymin = first;
      xmin = second;
      ymax = third;
      xmax = fourth;
    case BoxOrder.xyxy:
      xmin = first;
      ymin = second;
      xmax = third;
      ymax = fourth;
  }
  var left = xmin;
  var top = ymin;
  var right = xmax;
  var bottom = ymax;
  if (normalized) {
    left *= transform.dstWidth;
    right *= transform.dstWidth;
    top *= transform.dstHeight;
    bottom *= transform.dstHeight;
  }
  left = transform.mapXToSource(left);
  right = transform.mapXToSource(right);
  top = transform.mapYToSource(top);
  bottom = transform.mapYToSource(bottom);
  final maxX = transform.srcWidth.toDouble();
  final maxY = transform.srcHeight.toDouble();
  return SourceRect(
    left.clamp(0.0, maxX),
    top.clamp(0.0, maxY),
    right.clamp(0.0, maxX),
    bottom.clamp(0.0, maxY),
  );
}

/// Letterboxed content rectangle for a widget that uses [BoxFit.contain].
CanvasRect containFrame({
  required double canvasWidth,
  required double canvasHeight,
  required int imageWidth,
  required int imageHeight,
}) {
  if (canvasWidth <= 0 ||
      canvasHeight <= 0 ||
      imageWidth <= 0 ||
      imageHeight <= 0) {
    throw ArgumentError('Canvas and image dimensions must be positive.');
  }
  final scale = math.min(canvasWidth / imageWidth, canvasHeight / imageHeight);
  final width = imageWidth * scale;
  final height = imageHeight * scale;
  final left = (canvasWidth - width) / 2;
  final top = (canvasHeight - height) / 2;
  return CanvasRect(left, top, left + width, top + height);
}

/// Maps a source-pixel box onto the contained image inside a canvas.
CanvasRect mapSourceBoxToCanvas({
  required DetectionBox box,
  required double canvasWidth,
  required double canvasHeight,
  required int imageWidth,
  required int imageHeight,
}) {
  final frame = containFrame(
    canvasWidth: canvasWidth,
    canvasHeight: canvasHeight,
    imageWidth: imageWidth,
    imageHeight: imageHeight,
  );
  final scaleX = (frame.right - frame.left) / imageWidth;
  final scaleY = (frame.bottom - frame.top) / imageHeight;
  return CanvasRect(
    frame.left + box.left * scaleX,
    frame.top + box.top * scaleY,
    frame.left + box.right * scaleX,
    frame.top + box.bottom * scaleY,
  );
}
