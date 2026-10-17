import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_on_device_ml/src/detection/input_tensor.dart';
import 'package:flutter_on_device_ml/src/detection/labels.dart';
import 'package:flutter_on_device_ml/src/detection/model_config.dart';
import 'package:flutter_on_device_ml/src/detection/tensor_layout.dart';
import 'package:flutter_on_device_ml/src/imaging/pixel_image.dart';

void main() {
  test('named tensors keep their roles when the order is shuffled', () {
    final roles = assignOutputRoles(const [
      TensorSpec(name: 'num_detections', shape: [1]),
      TensorSpec(name: 'detection_scores', shape: [1, 10]),
      TensorSpec(name: 'detection_boxes', shape: [1, 10, 4]),
      TensorSpec(name: 'detection_classes', shape: [1, 10]),
    ]);

    expect(roles['boxes'], 2);
    expect(roles['classes'], 3);
    expect(roles['scores'], 1);
    expect(roles['count'], 0);
  });

  test('unnamed tensors fall back to shape and output order', () {
    final roles = assignOutputRoles(const [
      TensorSpec(name: '', shape: [1, 10]),
      TensorSpec(name: '', shape: [1]),
      TensorSpec(name: '', shape: [1, 10, 4]),
      TensorSpec(name: '', shape: [1, 10]),
    ]);

    expect(roles['boxes'], 2);
    expect(roles['count'], 1);
    expect(roles['classes'], 0);
    expect(roles['scores'], 3);
  });

  test('a graph without a box tensor is rejected', () {
    expect(
      () => assignOutputRoles(const [
        TensorSpec(name: 'detection_scores', shape: [1, 10]),
      ]),
      throwsFormatException,
    );
  });

  test('nested fill matches the tensor shape and flattens in order', () {
    final nested = nestedFill(const [1, 2, 4], 0);
    expect(nested, [
      [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
    ]);
    final flat = flattenNumbers(const [
      [
        [0.1, 0.2],
      ],
    ]);
    expect(flat, [0.1, 0.2]);
  });

  test('float input is normalized and uint8 input stays in range', () {
    final image = PixelImage.filled(1, 1, r: 255, g: 0, b: 128);
    final floating = buildInputTensor(
      image: image,
      shape: const [1, 1, 1, 3],
      floating: true,
      mean: 0,
      std: 255,
    );
    final bytes = buildInputTensor(
      image: image,
      shape: const [1, 1, 3],
      floating: false,
      mean: 0,
      std: 255,
    );

    expect(flattenNumbers(floating), [1, 0, 128 / 255]);
    expect(flattenNumbers(bytes), [255, 0, 128]);
  });

  test('model config rejects an impossible threshold', () {
    expect(
      () => ModelConfig.fromJson(const {'scoreThreshold': 2}),
      throwsFormatException,
    );
    expect(ModelConfig.fromJson(const {'boxOrder': 'xyxy'}).boxOrder, BoxOrder.xyxy);
  });

  test('bundled SSD label map keeps class indexes', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = await rootBundle.loadString(
      'assets/models/labelmap_ssd_mobilenet_v1.txt',
    );
    final labels = parseLabelFile(raw);
    expect(labels, hasLength(91));
    expect(labels.first, '???');
    expect(labels[1], 'person');
    expect(labels.last, 'toothbrush');
    expect(labelFor(labels, 1, 0), 'person');
    expect(labelFor(labels, 0, 0), 'class 0');
  });

  test('bundled model config parses', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = await rootBundle.loadString('assets/models/model_config.json');
    final decoded = jsonDecode(raw);
    expect(decoded, isA<Map>());
    final config = ModelConfig.fromJson((decoded as Map).cast<String, dynamic>());
    expect(config.inputWidth, 300);
    expect(config.inputHeight, 300);
    expect(config.letterbox, isTrue);
    expect(config.boxOrder, BoxOrder.yxyx);
    expect(config.classIndexBase, 0);
  });
}
