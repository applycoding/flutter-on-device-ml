import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter_on_device_ml/src/detection/detection_box.dart';
import 'package:flutter_on_device_ml/src/detection/image_transform.dart';
import 'package:flutter_on_device_ml/src/imaging/pixel_image.dart';
import 'package:flutter_on_device_ml/src/ocr/text_read.dart';

/// Photo with detection and text boxes in the same contain-fit as the image.
class DetectionOverlay extends StatefulWidget {
  const DetectionOverlay({
    super.key,
    required this.imageWidth,
    required this.imageHeight,
    required this.detections,
    this.regions = const [],
    this.pixels,
  });

  final int imageWidth;
  final int imageHeight;
  final List<DetectionBox> detections;
  final List<TextRegion> regions;
  final PixelImage? pixels;

  @override
  State<DetectionOverlay> createState() => _DetectionOverlayState();
}

class _DetectionOverlayState extends State<DetectionOverlay> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(DetectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pixels != widget.pixels) {
      _image?.dispose();
      _image = null;
      _decode();
    }
  }

  Future<void> _decode() async {
    final pixels = widget.pixels;
    if (pixels == null) return;
    try {
      final image = await _rgbaImage(pixels);
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() => _image = image);
    } on Object {
      // Boxes still paint when the photo cannot be decoded.
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 360,
      width: double.infinity,
      child: CustomPaint(
        key: const Key('detection-overlay'),
        painter: DetectionBoxPainter(
          imageWidth: widget.imageWidth,
          imageHeight: widget.imageHeight,
          detections: widget.detections,
          regions: widget.regions,
          image: _image,
          boxColor: theme.colorScheme.tertiary,
          textColor: theme.colorScheme.primary,
          frameColor: theme.colorScheme.surfaceContainerHighest,
          background: theme.scaffoldBackgroundColor,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

Future<ui.Image> _rgbaImage(PixelImage pixels) {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels.rgba,
    pixels.width,
    pixels.height,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  return completer.future;
}

class DetectionBoxPainter extends CustomPainter {
  DetectionBoxPainter({
    required this.imageWidth,
    required this.imageHeight,
    required this.detections,
    required this.regions,
    required this.boxColor,
    required this.textColor,
    required this.frameColor,
    required this.background,
    this.image,
  });

  final int imageWidth;
  final int imageHeight;
  final List<DetectionBox> detections;
  final List<TextRegion> regions;
  final ui.Image? image;
  final Color boxColor;
  final Color textColor;
  final Color frameColor;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = containFrame(
      canvasWidth: size.width,
      canvasHeight: size.height,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    final content = Rect.fromLTRB(frame.left, frame.top, frame.right, frame.bottom);
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final photo = image;
    if (photo != null) {
      canvas.drawImageRect(
        photo,
        Rect.fromLTWH(0, 0, photo.width.toDouble(), photo.height.toDouble()),
        content,
        Paint()..filterQuality = FilterQuality.medium,
      );
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(content, const Radius.circular(12)),
        Paint()..color = frameColor,
      );
    }
    for (final detection in detections) {
      final rect = _rectFor(detection, size);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = boxColor,
      );
      _paintLabel(canvas, detection.label, rect, boxColor);
    }
    for (final region in regions) {
      final rect = _rectFor(
        DetectionBox(
          left: region.left,
          top: region.top,
          right: region.right,
          bottom: region.bottom,
          score: 0,
          classId: -1,
          label: region.text,
        ),
        size,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = textColor,
      );
    }
  }

  Rect _rectFor(DetectionBox box, Size size) {
    final mapped = mapSourceBoxToCanvas(
      box: box,
      canvasWidth: size.width,
      canvasHeight: size.height,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    return Rect.fromLTRB(mapped.left, mapped.top, mapped.right, mapped.bottom);
  }

  void _paintLabel(Canvas canvas, String label, Rect rect, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 220);
    final top = rect.top - painter.height - 6;
    final labelTop = top < 0 ? rect.top + 4 : top;
    final background = Rect.fromLTWH(
      rect.left,
      labelTop,
      painter.width + 8,
      painter.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(background, const Radius.circular(4)),
      Paint()..color = color,
    );
    painter.paint(canvas, Offset(rect.left + 4, labelTop + 2));
  }

  @override
  bool shouldRepaint(DetectionBoxPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.detections != detections ||
        oldDelegate.regions != regions ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight;
  }
}
