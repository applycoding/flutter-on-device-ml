/// How a detection model orders the four values of one box.
enum BoxOrder { yxyx, xyxy }

/// Settings for a post-processed detection graph.
///
/// The interpreter's input tensor wins over [inputWidth] and [inputHeight]
/// when they disagree. Those fields document the checkpoint you configured.
class ModelConfig {
  const ModelConfig({
    this.name = 'ssd_mobilenet_v1_coco_quant_2018',
    this.inputWidth = 300,
    this.inputHeight = 300,
    this.scoreThreshold = 0.5,
    this.iouThreshold = 0.45,
    this.letterbox = true,
    this.applyNms = true,
    this.floatMean = 0,
    this.floatStd = 255,
    this.classIndexBase = 0,
    this.normalizedBoxes = true,
    this.boxOrder = BoxOrder.yxyx,
    this.labelsAsset = 'assets/models/labelmap_ssd_mobilenet_v1.txt',
    this.outputOrder = defaultOutputOrder,
  });

  static const defaultOutputOrder = ['boxes', 'classes', 'scores', 'count'];

  final String name;
  final int inputWidth;
  final int inputHeight;
  final double scoreThreshold;
  final double iouThreshold;
  final bool letterbox;
  final bool applyNms;
  final double floatMean;
  final double floatStd;
  final int classIndexBase;
  final bool normalizedBoxes;
  final BoxOrder boxOrder;
  final String labelsAsset;
  final List<String> outputOrder;

  factory ModelConfig.fromJson(Map<String, dynamic> json) {
    final config = ModelConfig(
      name: _string(json, 'name') ?? 'detection',
      inputWidth: _int(json, 'inputWidth') ?? 300,
      inputHeight: _int(json, 'inputHeight') ?? 300,
      scoreThreshold: _double(json, 'scoreThreshold') ?? 0.5,
      iouThreshold: _double(json, 'iouThreshold') ?? 0.45,
      letterbox: _bool(json, 'letterbox') ?? true,
      applyNms: _bool(json, 'applyNms') ?? true,
      floatMean: _double(json, 'floatMean') ?? 0,
      floatStd: _double(json, 'floatStd') ?? 255,
      classIndexBase: _int(json, 'classIndexBase') ?? 0,
      normalizedBoxes: _bool(json, 'normalizedBoxes') ?? true,
      boxOrder: _boxOrder(json['boxOrder']),
      labelsAsset:
          _string(json, 'labelsAsset') ??
          'assets/models/labelmap_ssd_mobilenet_v1.txt',
      outputOrder: _outputOrder(json['outputOrder']),
    );
    config.validate();
    return config;
  }

  void validate() {
    if (inputWidth <= 0 || inputHeight <= 0) {
      throw const FormatException('inputWidth and inputHeight must be positive.');
    }
    if (scoreThreshold < 0 || scoreThreshold > 1) {
      throw const FormatException('scoreThreshold must be between 0 and 1.');
    }
    if (iouThreshold < 0 || iouThreshold > 1) {
      throw const FormatException('iouThreshold must be between 0 and 1.');
    }
    if (floatStd == 0) {
      throw const FormatException('floatStd must not be 0.');
    }
    if (labelsAsset.trim().isEmpty) {
      throw const FormatException('labelsAsset must not be empty.');
    }
    const required = {'boxes', 'classes', 'scores'};
    if (!required.every(outputOrder.contains)) {
      throw const FormatException(
        'outputOrder must include boxes, classes, and scores.',
      );
    }
  }
}

BoxOrder _boxOrder(Object? value) {
  if (value == null) return BoxOrder.yxyx;
  if (value is! String) {
    throw const FormatException('boxOrder must be "yxyx" or "xyxy".');
  }
  switch (value) {
    case 'yxyx':
      return BoxOrder.yxyx;
    case 'xyxy':
      return BoxOrder.xyxy;
    default:
      throw FormatException('Unknown boxOrder "$value".');
  }
}

List<String> _outputOrder(Object? value) {
  if (value == null) return ModelConfig.defaultOutputOrder;
  if (value is! List) {
    throw const FormatException('outputOrder must be a list of strings.');
  }
  return [for (final item in value) item.toString()];
}

String? _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('$key must be a string.');
}

int? _int(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  throw FormatException('$key must be an integer.');
}

double? _double(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is num) return value.toDouble();
  throw FormatException('$key must be a number.');
}

bool? _bool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is bool) return value;
  throw FormatException('$key must be a boolean.');
}
