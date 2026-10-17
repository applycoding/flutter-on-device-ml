/// One object box in source-image pixels, after coordinate mapping.
class DetectionBox {
  const DetectionBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.score,
    required this.classId,
    required this.label,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;
  final double score;
  final int classId;
  final String label;

  double get width => right - left;
  double get height => bottom - top;

  bool get isEmpty => width <= 0 || height <= 0;

  Map<String, Object> toJson() {
    return {
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
      'score': score,
      'classId': classId,
      'label': label,
    };
  }

  factory DetectionBox.fromJson(Map<String, dynamic> json) {
    return DetectionBox(
      left: _requiredDouble(json, 'left'),
      top: _requiredDouble(json, 'top'),
      right: _requiredDouble(json, 'right'),
      bottom: _requiredDouble(json, 'bottom'),
      score: _requiredDouble(json, 'score'),
      classId: _requiredInt(json, 'classId'),
      label: json['label'] as String? ?? '',
    );
  }
}

double _requiredDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value.toDouble();
  throw FormatException('$key must be a number.');
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.round();
  throw FormatException('$key must be an integer.');
}
