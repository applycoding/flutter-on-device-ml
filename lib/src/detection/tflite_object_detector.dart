import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:flutter_on_device_ml/src/detection/detection_box.dart';
import 'package:flutter_on_device_ml/src/detection/detection_decoder.dart';
import 'package:flutter_on_device_ml/src/detection/detection_exception.dart';
import 'package:flutter_on_device_ml/src/detection/image_transform.dart';
import 'package:flutter_on_device_ml/src/detection/input_tensor.dart';
import 'package:flutter_on_device_ml/src/detection/labels.dart';
import 'package:flutter_on_device_ml/src/detection/model_config.dart';
import 'package:flutter_on_device_ml/src/detection/object_detector.dart';
import 'package:flutter_on_device_ml/src/detection/tensor_layout.dart';
import 'package:flutter_on_device_ml/src/imaging/pixel_image.dart';

/// TensorFlow Lite detector for graphs that already include detection
/// post-processing (boxes, classes, scores, and usually a count).
///
/// The CPU interpreter is used. GPU and NNAPI delegates are not enabled.
/// A model file is loaded from the application support directory
/// `models/detect.tflite` when that file exists, otherwise from
/// `assets/models/detect.tflite`.
class TfliteObjectDetector implements ObjectDetector {
  TfliteObjectDetector({this.modelFileName = 'detect.tflite'});

  final String modelFileName;

  Interpreter? _interpreter;
  InterpreterOptions? _options;
  ModelConfig? _config;
  List<String>? _labels;

  @override
  String get name => 'TensorFlow Lite';

  @override
  Future<bool> isModelReady() async {
    try {
      final file = await _modelFile();
      if (await file.exists()) return true;
      await rootBundle.load('assets/models/$modelFileName');
      return true;
    } on Object {
      return false;
    }
  }

  @override
  Future<List<DetectionBox>> detect(PixelImage image) async {
    await _ensureMetadata();
    final config = _config ?? const ModelConfig();
    final labels = _labels ?? const <String>[];
    final interpreter = await _openInterpreter();
    interpreter.allocateTensors();
    final inputTensor = interpreter.getInputTensor(0);
    final inputShape = inputTensor.shape;
    final spatial = _spatialSize(inputShape);
    final fitted = fitImage(
      image,
      dstWidth: spatial.width,
      dstHeight: spatial.height,
      letterbox: config.letterbox,
    );
    final floating = inputTensor.type == TensorType.float32;
    if (!floating && inputTensor.type != TensorType.uint8) {
      throw DetectionException(
        'This model input type (${inputTensor.type.name}) is not supported. Use uint8 or float32.',
      );
    }
    final input = buildInputTensor(
      image: fitted.image,
      shape: inputShape,
      floating: floating,
      mean: config.floatMean,
      std: config.floatStd,
    );
    final tensors = interpreter.getOutputTensors();
    final outputs = <int, Object>{};
    final specs = <TensorSpec>[];
    for (var i = 0; i < tensors.length; i++) {
      final tensor = tensors[i];
      if (tensor.type != TensorType.float32) {
        throw DetectionException(
          'Output "${tensor.name}" is ${tensor.type.name}. This app reads float32 detection outputs.',
        );
      }
      outputs[i] = nestedFill(tensor.shape, 0.0);
      specs.add(TensorSpec(name: tensor.name, shape: tensor.shape));
    }
    final Map<String, int> roles;
    try {
      roles = assignOutputRoles(specs, fallbackOrder: config.outputOrder);
    } on FormatException catch (error) {
      throw DetectionException(error.message);
    }
    interpreter.runForMultipleInputs([input], outputs);
    final boxIndex = roles['boxes'];
    final classIndex = roles['classes'];
    final scoreIndex = roles['scores'];
    if (boxIndex == null || classIndex == null || scoreIndex == null) {
      throw const DetectionException(
        'The model output is missing boxes, classes, or scores.',
      );
    }
    final boxValues = flattenNumbers(outputs[boxIndex]!);
    final scoreValues = flattenNumbers(outputs[scoreIndex]!);
    final classValues = flattenNumbers(outputs[classIndex]!);
    final countIndex = roles['count'];
    var count = scoreValues.length;
    if (countIndex != null) {
      final countValues = flattenNumbers(outputs[countIndex]!);
      if (countValues.isNotEmpty) count = countValues.first.round();
    }
    if (count < 0) count = 0;
    if (count > scoreValues.length) count = scoreValues.length;
    final boxCount = boxValues.length ~/ 4;
    if (count > boxCount) count = boxCount;
    if (count > classValues.length) count = classValues.length;
    return decodeDetections(
      values: boxValues.sublist(0, count * 4),
      scores: scoreValues.sublist(0, count),
      classIds: [for (final value in classValues.take(count)) value.round()],
      transform: fitted.transform,
      labels: labels,
      config: config,
    );
  }

  @override
  void close() {
    _interpreter?.close();
    _interpreter = null;
    _options?.delete();
    _options = null;
  }

  Future<void> _ensureMetadata() async {
    if (_config != null && _labels != null) return;
    final config = await _loadConfig();
    _config = config;
    _labels = await _loadLabels(config);
  }

  Future<ModelConfig> _loadConfig() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/models/model_config.json',
      );
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const ModelConfig();
      }
      return ModelConfig.fromJson(decoded.cast<String, dynamic>());
    } on Object {
      return const ModelConfig();
    }
  }

  Future<List<String>> _loadLabels(ModelConfig config) async {
    try {
      final raw = await rootBundle.loadString(config.labelsAsset);
      return parseLabelFile(raw);
    } on Object {
      return const [];
    }
  }

  Future<Interpreter> _openInterpreter() async {
    final existing = _interpreter;
    if (existing != null) return existing;
    final file = await _modelFile();
    final options = InterpreterOptions()..threads = 2;
    _options = options;
    try {
      if (await file.exists()) {
        try {
          final interpreter = Interpreter.fromFile(file, options: options);
          _interpreter = interpreter;
          return interpreter;
        } on Object catch (error) {
          throw DetectionException(
            'The detection model file could not be opened. $error',
          );
        }
      }
      try {
        final interpreter = await Interpreter.fromAsset(
          'assets/models/$modelFileName',
          options: options,
        );
        _interpreter = interpreter;
        return interpreter;
      } on DetectionException {
        rethrow;
      } on Object {
        throw const DetectionException(
          'No detection model is installed. Download an SSD MobileNet or EfficientDet-Lite TensorFlow Lite model and add it to the app. See Model setup.',
          modelMissing: true,
        );
      }
    } on DetectionException {
      options.delete();
      _options = null;
      rethrow;
    }
  }

  Future<File> _modelFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'models', modelFileName));
  }
}

({int width, int height}) _spatialSize(List<int> shape) {
  if (shape.length == 4 && shape[3] == 3) {
    return (width: shape[2], height: shape[1]);
  }
  if (shape.length == 3 && shape[2] == 3) {
    return (width: shape[1], height: shape[0]);
  }
  throw DetectionException(
    'Unsupported input shape $shape. Expected NHWC with 3 channels.',
  );
}
