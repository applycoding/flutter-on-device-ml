import 'package:flutter_on_device_ml/src/detection/detection_box.dart';
import 'package:flutter_on_device_ml/src/detection/object_detector.dart';
import 'package:flutter_on_device_ml/src/imaging/image_gateway.dart';
import 'package:flutter_on_device_ml/src/imaging/pixel_image.dart';
import 'package:flutter_on_device_ml/src/ocr/text_read.dart';
import 'package:flutter_on_device_ml/src/ocr/text_reader.dart';

class FakeObjectDetector implements ObjectDetector {
  FakeObjectDetector({
    this.detections = const [],
    this.ready = true,
    this.error,
  });

  List<DetectionBox> detections;
  bool ready;
  Object? error;
  int detectCalls = 0;
  PixelImage? lastImage;

  @override
  String get name => 'Fake detector';

  @override
  Future<bool> isModelReady() async => ready;

  @override
  Future<List<DetectionBox>> detect(PixelImage image) async {
    detectCalls += 1;
    lastImage = image;
    final failure = error;
    if (failure != null) throw failure;
    return detections;
  }

  @override
  void close() {}
}

class FakeTextReader implements TextReader {
  FakeTextReader({this.reading = const TextRead(text: '', regions: [])});

  TextRead reading;
  Object? error;
  int reads = 0;

  @override
  Future<TextRead> read(PickedPhoto photo) async {
    reads += 1;
    final failure = error;
    if (failure != null) throw failure;
    return reading;
  }

  @override
  void close() {}
}

class FakeImageGateway implements ImageGateway {
  FakeImageGateway(this.photo, {this.lost});

  PickedPhoto? photo;
  PickedPhoto? lost;
  ImageOrigin? lastOrigin;
  int picks = 0;

  @override
  Future<PickedPhoto?> pick(ImageOrigin origin) async {
    picks += 1;
    lastOrigin = origin;
    return photo;
  }

  @override
  Future<PickedPhoto?> recoverLost() async => lost;
}

PixelImage samplePhoto() {
  final image = PixelImage.filled(4, 2, r: 20, g: 40, b: 60);
  image.setPixel(0, 0, 200, 10, 10);
  return image;
}

PickedPhoto samplePick() => PickedPhoto(image: samplePhoto(), path: null);
