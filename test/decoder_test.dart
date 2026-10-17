import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_on_device_ml/src/detection/detection_decoder.dart';
import 'package:flutter_on_device_ml/src/detection/detection_exception.dart';
import 'package:flutter_on_device_ml/src/detection/image_transform.dart';
import 'package:flutter_on_device_ml/src/detection/labels.dart';
import 'package:flutter_on_device_ml/src/detection/model_config.dart';

void main() {
  const labels = ['???', 'person', 'cup'];
  final transform = computeTransform(
    srcWidth: 640,
    srcHeight: 480,
    dstWidth: 320,
    dstHeight: 320,
    letterbox: true,
  );
  const config = ModelConfig(
    scoreThreshold: 0.5,
    iouThreshold: 0.4,
    classIndexBase: 0,
  );

  List<double> yxyx(double ymin, double xmin, double ymax, double xmax) {
    return [ymin, xmin, ymax, xmax];
  }

  test('decoder maps, filters, labels, and suppresses overlaps', () {
    final content = yxyx(40 / 320, 0.25, 280 / 320, 0.75);
    final overlap = yxyx(50 / 320, 0.30, 270 / 320, 0.70);
    final padding = yxyx(0, 0, 40 / 320, 1);
    final weak = yxyx(40 / 320, 0, 80 / 320, 0.2);

    final boxes = decodeDetections(
      values: [...content, ...overlap, ...padding, ...weak],
      scores: const [0.91, 0.80, 0.99, 0.2],
      classIds: const [2, 2, 1, 1],
      transform: transform,
      labels: labels,
      config: config,
    );

    expect(boxes, hasLength(1));
    expect(boxes.single.label, 'cup');
    expect(boxes.single.score, 0.91);
    expect(boxes.single.left, 160);
    expect(boxes.single.right, 480);
    expect(boxes.single.top, 0);
    expect(boxes.single.bottom, 480);
  });

  test('classIndexBase 1 reads person from a compact label list', () {
    final boxes = decodeDetections(
      values: [40 / 320, 0, 280 / 320, 1],
      scores: const [0.7],
      classIds: const [1],
      transform: transform,
      labels: const ['person', 'bicycle'],
      config: const ModelConfig(classIndexBase: 1, applyNms: false),
    );

    expect(boxes.single.label, 'person');
  });

  test('a placeholder label becomes class N', () {
    expect(labelFor(labels, 0, 0), 'class 0');
    expect(labelFor(const ['person'], 4, 0), 'class 4');
  });

  test('mismatched tensor lengths are rejected', () {
    expect(
      () => decodeDetections(
        values: const [0, 0, 1, 1, 0],
        scores: const [0.9],
        classIds: const [1],
        transform: transform,
        labels: labels,
        config: config,
      ),
      throwsA(isA<DetectionException>()),
    );
  });
}
