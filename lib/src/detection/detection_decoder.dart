import 'package:flutter_on_device_ml/src/detection/detection_box.dart';
import 'package:flutter_on_device_ml/src/detection/detection_exception.dart';
import 'package:flutter_on_device_ml/src/detection/image_transform.dart';
import 'package:flutter_on_device_ml/src/detection/labels.dart';
import 'package:flutter_on_device_ml/src/detection/model_config.dart';
import 'package:flutter_on_device_ml/src/detection/nms.dart';

/// Turns raw detection tensors into source-pixel boxes.
///
/// [values] is packed box coordinates, four numbers per detection, in
/// [ModelConfig.boxOrder]. [scores] and [classIds] are parallel to those boxes.
List<DetectionBox> decodeDetections({
  required List<double> values,
  required List<double> scores,
  required List<int> classIds,
  required ImageTransform transform,
  required List<String> labels,
  required ModelConfig config,
}) {
  if (values.length != scores.length * 4 || classIds.length != scores.length) {
    throw const DetectionException(
      'This model output is not a list of boxes, classes, and scores.',
    );
  }
  final decoded = <DetectionBox>[];
  for (var i = 0; i < scores.length; i++) {
    final score = scores[i];
    if (score < config.scoreThreshold) continue;
    final rect = mapModelBoxToSource(
      first: values[i * 4],
      second: values[i * 4 + 1],
      third: values[i * 4 + 2],
      fourth: values[i * 4 + 3],
      transform: transform,
      normalized: config.normalizedBoxes,
      order: config.boxOrder,
    );
    if (rect.isEmpty) continue;
    final classId = classIds[i];
    decoded.add(
      DetectionBox(
        left: rect.left,
        top: rect.top,
        right: rect.right,
        bottom: rect.bottom,
        score: score,
        classId: classId,
        label: labelFor(labels, classId, config.classIndexBase),
      ),
    );
  }
  if (!config.applyNms) return decoded;
  return nonMaxSuppression(
    decoded,
    iouThreshold: config.iouThreshold,
    scoreThreshold: config.scoreThreshold,
  );
}
