/// One interpreter tensor, described without loading TensorFlow Lite.
class TensorSpec {
  const TensorSpec({required this.name, required this.shape});

  final String name;
  final List<int> shape;

  int get elements {
    var count = 1;
    for (final dim in shape) {
      count *= dim;
    }
    return count;
  }
}

/// Assigns output tensors to boxes, classes, scores, and an optional count.
///
/// Names such as `detection_boxes` win. Otherwise a trailing dimension of 4 is
/// the box tensor and a single element is the count. Anything left is filled
/// from [fallbackOrder], which is the model config's `outputOrder`.
Map<String, int> assignOutputRoles(
  List<TensorSpec> tensors, {
  List<String> fallbackOrder = ModelOutputRoles.fallback,
}) {
  if (tensors.isEmpty) {
    throw const FormatException('The model has no output tensors.');
  }
  final assigned = <String, int>{};
  final used = <int>{};

  for (var i = 0; i < tensors.length; i++) {
    final role = _roleFromName(tensors[i].name);
    if (role == null || assigned.containsKey(role)) continue;
    assigned[role] = i;
    used.add(i);
  }

  for (var i = 0; i < tensors.length; i++) {
    if (used.contains(i)) continue;
    final shape = tensors[i].shape;
    if (!assigned.containsKey('boxes') &&
        shape.length >= 2 &&
        shape.last == 4) {
      assigned['boxes'] = i;
      used.add(i);
      continue;
    }
    if (!assigned.containsKey('count') && tensors[i].elements == 1) {
      assigned['count'] = i;
      used.add(i);
    }
  }

  final remainingRoles = [
    for (final role in fallbackOrder)
      if (!assigned.containsKey(role)) role,
  ];
  final remainingIndexes = [
    for (var i = 0; i < tensors.length; i++)
      if (!used.contains(i)) i,
  ];
  final pairs = remainingRoles.length < remainingIndexes.length
      ? remainingRoles.length
      : remainingIndexes.length;
  for (var i = 0; i < pairs; i++) {
    assigned[remainingRoles[i]] = remainingIndexes[i];
  }

  for (final role in const ['boxes', 'classes', 'scores']) {
    if (!assigned.containsKey(role)) {
      throw FormatException('Could not find the $role output on this model.');
    }
  }
  return assigned;
}

String? _roleFromName(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('score')) return 'scores';
  if (lower.contains('class')) return 'classes';
  if (lower.contains('box') || lower.contains('location')) return 'boxes';
  if (lower.contains('count') || lower.contains('num_det')) return 'count';
  return null;
}

abstract final class ModelOutputRoles {
  static const fallback = ['boxes', 'classes', 'scores', 'count'];
}

/// Builds a nested list whose shape matches [shape]. Each leaf is [fill].
Object nestedFill(List<int> shape, num fill) {
  if (shape.isEmpty) return fill;
  if (shape.any((dim) => dim <= 0)) {
    throw ArgumentError('Tensor dimensions must be positive.');
  }
  Object build(int axis) {
    if (axis == shape.length - 1) {
      return List<num>.filled(shape[axis], fill, growable: false);
    }
    return List<Object>.generate(
      shape[axis],
      (_) => build(axis + 1),
      growable: false,
    );
  }

  return build(0);
}

/// Flattens nested numeric lists left to right.
List<double> flattenNumbers(Object node) {
  if (node is num) return [node.toDouble()];
  if (node is List) {
    final out = <double>[];
    for (final item in node) {
      out.addAll(flattenNumbers(item as Object));
    }
    return out;
  }
  throw ArgumentError('Cannot flatten ${node.runtimeType}.');
}
