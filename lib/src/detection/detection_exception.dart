/// A detection failure the UI can show. [modelMissing] opens the setup guide.
class DetectionException implements Exception {
  const DetectionException(this.message, {this.modelMissing = false});

  final String message;
  final bool modelMissing;

  @override
  String toString() => message;
}
