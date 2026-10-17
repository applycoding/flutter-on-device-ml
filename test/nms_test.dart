import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_on_device_ml/src/detection/detection_box.dart';
import 'package:flutter_on_device_ml/src/detection/nms.dart';

DetectionBox box({
  required double left,
  required double top,
  required double right,
  required double bottom,
  required double score,
  int classId = 1,
  String label = 'cup',
}) {
  return DetectionBox(
    left: left,
    top: top,
    right: right,
    bottom: bottom,
    score: score,
    classId: classId,
    label: label,
  );
}

void main() {
  test('identical boxes have IoU 1 and disjoint boxes have IoU 0', () {
    final first = box(left: 0, top: 0, right: 2, bottom: 2, score: 1);
    final copy = box(left: 0, top: 0, right: 2, bottom: 2, score: 0.2);
    final apart = box(left: 3, top: 0, right: 4, bottom: 2, score: 0.2);
    final touching = box(left: 2, top: 0, right: 4, bottom: 2, score: 0.2);

    expect(intersectionOverUnion(first, copy), 1);
    expect(intersectionOverUnion(first, apart), 0);
    expect(intersectionOverUnion(first, touching), 0);
  });

  test('partial overlap matches the hand-computed IoU', () {
    final a = box(left: 0, top: 0, right: 2, bottom: 2, score: 1);
    final b = box(left: 1, top: 1, right: 3, bottom: 3, score: 1);

    expect(intersectionOverUnion(a, b), closeTo(1 / 7, 1e-12));
  });

  test('NMS keeps the higher score when overlap exceeds the threshold', () {
    final kept = nonMaxSuppression(
      [
        box(left: 0, top: 0, right: 2, bottom: 2, score: 0.9),
        box(left: 1, top: 1, right: 3, bottom: 3, score: 0.4),
      ],
      iouThreshold: 0.1,
    );

    expect(kept, hasLength(1));
    expect(kept.single.score, 0.9);
  });

  test('NMS keeps both boxes when overlap is under the threshold', () {
    final kept = nonMaxSuppression(
      [
        box(left: 0, top: 0, right: 2, bottom: 2, score: 0.9),
        box(left: 1, top: 1, right: 3, bottom: 3, score: 0.4),
      ],
      iouThreshold: 0.5,
    );

    expect(kept.map((item) => item.score), [0.9, 0.4]);
  });

  test('NMS does not suppress a different class', () {
    final kept = nonMaxSuppression(
      [
        box(left: 0, top: 0, right: 2, bottom: 2, score: 0.9, classId: 1),
        box(
          left: 0,
          top: 0,
          right: 2,
          bottom: 2,
          score: 0.8,
          classId: 2,
          label: 'book',
        ),
      ],
      iouThreshold: 0.1,
    );

    expect(kept.map((item) => item.classId), [1, 2]);
  });

  test('score threshold drops weaker boxes and keeps an equal score', () {
    final kept = nonMaxSuppression(
      [
        box(left: 0, top: 0, right: 1, bottom: 1, score: 0.5),
        box(left: 5, top: 5, right: 6, bottom: 6, score: 0.49),
      ],
      iouThreshold: 0.5,
      scoreThreshold: 0.5,
    );

    expect(kept, hasLength(1));
    expect(kept.single.score, 0.5);
  });

  test('equal scores keep the earlier box', () {
    final first = box(left: 0, top: 0, right: 2, bottom: 2, score: 0.5, label: 'first');
    final second = box(left: 0, top: 0, right: 2, bottom: 2, score: 0.5, label: 'second');
    final kept = nonMaxSuppression(
      [first, second],
      iouThreshold: 0.5,
    );

    expect(kept.single.label, 'first');
  });

  test('empty input stays empty', () {
    expect(nonMaxSuppression(const [], iouThreshold: 0.5), isEmpty);
  });
}
