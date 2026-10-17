import 'package:flutter_on_device_ml/src/detection/detection_box.dart';

/// Intersection over union for axis-aligned boxes. Touching edges have IoU 0.
double intersectionOverUnion(DetectionBox a, DetectionBox b) {
  final interLeft = a.left > b.left ? a.left : b.left;
  final interTop = a.top > b.top ? a.top : b.top;
  final interRight = a.right < b.right ? a.right : b.right;
  final interBottom = a.bottom < b.bottom ? a.bottom : b.bottom;
  final interWidth = interRight - interLeft;
  final interHeight = interBottom - interTop;
  if (interWidth <= 0 || interHeight <= 0) return 0;
  final intersection = interWidth * interHeight;
  final areaA = _area(a);
  final areaB = _area(b);
  final union = areaA + areaB - intersection;
  if (union <= 0) return 0;
  return intersection / union;
}

double _area(DetectionBox box) {
  final width = box.right - box.left;
  final height = box.bottom - box.top;
  if (width <= 0 || height <= 0) return 0;
  return width * height;
}

/// Class-aware greedy NMS.
///
/// Boxes are kept when [score] is greater than or equal to [scoreThreshold].
/// A lower-scoring box is dropped when its IoU with a kept box of the same
/// class is greater than [iouThreshold]. Equal scores keep the earlier input
/// first.
List<DetectionBox> nonMaxSuppression(
  List<DetectionBox> boxes, {
  required double iouThreshold,
  double scoreThreshold = 0,
}) {
  final filtered = <_IndexedBox>[];
  for (var i = 0; i < boxes.length; i++) {
    if (boxes[i].score >= scoreThreshold) {
      filtered.add(_IndexedBox(i, boxes[i]));
    }
  }
  filtered.sort((a, b) {
    final byScore = b.box.score.compareTo(a.box.score);
    if (byScore != 0) return byScore;
    return a.index.compareTo(b.index);
  });
  final suppressed = List<bool>.filled(filtered.length, false);
  final kept = <DetectionBox>[];
  for (var i = 0; i < filtered.length; i++) {
    if (suppressed[i]) continue;
    kept.add(filtered[i].box);
    for (var j = i + 1; j < filtered.length; j++) {
      if (suppressed[j]) continue;
      if (filtered[j].box.classId != filtered[i].box.classId) continue;
      final overlap = intersectionOverUnion(filtered[i].box, filtered[j].box);
      if (overlap > iouThreshold) suppressed[j] = true;
    }
  }
  return kept;
}

class _IndexedBox {
  const _IndexedBox(this.index, this.box);
  final int index;
  final DetectionBox box;
}
