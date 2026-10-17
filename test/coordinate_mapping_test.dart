import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_on_device_ml/src/detection/detection_box.dart';
import 'package:flutter_on_device_ml/src/detection/image_transform.dart';
import 'package:flutter_on_device_ml/src/detection/model_config.dart';

void main() {
  final letterbox = computeTransform(
    srcWidth: 640,
    srcHeight: 480,
    dstWidth: 320,
    dstHeight: 320,
    letterbox: true,
  );

  test('a content-covering normalized box maps back to the source', () {
    final mapped = mapModelBoxToSource(
      first: 40 / 320,
      second: 0,
      third: 280 / 320,
      fourth: 1,
      transform: letterbox,
      normalized: true,
      order: BoxOrder.yxyx,
    );

    expect(mapped.left, 0);
    expect(mapped.top, 0);
    expect(mapped.right, 640);
    expect(mapped.bottom, 480);
    expect(mapped.isEmpty, isFalse);
  });

  test('the same box in absolute pixels and xyxy order matches', () {
    final mapped = mapModelBoxToSource(
      first: 0,
      second: 40,
      third: 320,
      fourth: 280,
      transform: letterbox,
      normalized: false,
      order: BoxOrder.xyxy,
    );

    expect(mapped.left, 0);
    expect(mapped.top, 0);
    expect(mapped.right, 640);
    expect(mapped.bottom, 480);
  });

  test('a box that only covers padding clamps to an empty edge', () {
    final mapped = mapModelBoxToSource(
      first: 0,
      second: 0,
      third: 40 / 320,
      fourth: 1,
      transform: letterbox,
      normalized: true,
      order: BoxOrder.yxyx,
    );

    expect(mapped.top, 0);
    expect(mapped.bottom, 0);
    expect(mapped.isEmpty, isTrue);
  });

  test('stretch mapping uses independent axis scales', () {
    final transform = computeTransform(
      srcWidth: 4,
      srcHeight: 2,
      dstWidth: 4,
      dstHeight: 4,
      letterbox: false,
    );
    final mapped = mapModelBoxToSource(
      first: 0,
      second: 0,
      third: 1,
      fourth: 1,
      transform: transform,
      normalized: true,
      order: BoxOrder.xyxy,
    );

    expect(mapped.left, 0);
    expect(mapped.top, 0);
    expect(mapped.right, 4);
    expect(mapped.bottom, 2);
  });

  test('overlay contain-fit pads a wide photo inside a square canvas', () {
    const box = DetectionBox(
      left: 0,
      top: 0,
      right: 100,
      bottom: 50,
      score: 1,
      classId: 1,
      label: 'cup',
    );
    final frame = containFrame(
      canvasWidth: 100,
      canvasHeight: 100,
      imageWidth: 100,
      imageHeight: 50,
    );
    final mapped = mapSourceBoxToCanvas(
      box: box,
      canvasWidth: 100,
      canvasHeight: 100,
      imageWidth: 100,
      imageHeight: 50,
    );

    expect(frame.left, 0);
    expect(frame.top, 25);
    expect(frame.right, 100);
    expect(frame.bottom, 75);
    expect(mapped.left, 0);
    expect(mapped.top, 25);
    expect(mapped.right, 100);
    expect(mapped.bottom, 75);
  });
}
