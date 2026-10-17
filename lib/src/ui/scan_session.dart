import 'package:flutter/foundation.dart';

import 'package:flutter_on_device_ml/src/detection/detection_box.dart';
import 'package:flutter_on_device_ml/src/detection/detection_exception.dart';
import 'package:flutter_on_device_ml/src/detection/object_detector.dart';
import 'package:flutter_on_device_ml/src/history/history_entry.dart';
import 'package:flutter_on_device_ml/src/imaging/image_gateway.dart';
import 'package:flutter_on_device_ml/src/ocr/text_read.dart';
import 'package:flutter_on_device_ml/src/ocr/text_reader.dart';

enum ScanPhase { chooseSource, running, result, failed }

/// Runs one camera or gallery scan and stores it in history.
class ScanSession extends ChangeNotifier {
  ScanSession({
    required this.kind,
    required this.detector,
    required this.reader,
    required this.images,
    required this.history,
    required this.imageStore,
    DateTime Function()? clock,
    String Function()? idFactory,
  }) : _clock = clock ?? DateTime.now,
       _idFactory =
           idFactory ??
           (() => DateTime.now().microsecondsSinceEpoch.toString());

  final ScanKind kind;
  final ObjectDetector detector;
  final TextReader reader;
  final ImageGateway images;
  final HistoryRepository history;
  final ImageStore imageStore;
  final DateTime Function() _clock;
  final String Function() _idFactory;

  ScanPhase phase = ScanPhase.chooseSource;
  PickedPhoto? photo;
  List<DetectionBox> detections = const [];
  TextRead? reading;
  String? errorMessage;
  bool modelMissing = false;
  HistoryEntry? saved;

  Future<void> pick(ImageOrigin origin) async {
    phase = ScanPhase.running;
    errorMessage = null;
    modelMissing = false;
    notifyListeners();
    try {
      final picked = await images.pick(origin);
      if (picked == null) {
        phase = ScanPhase.chooseSource;
        notifyListeners();
        return;
      }
      photo = picked;
      switch (kind) {
        case ScanKind.objectDetection:
          detections = await detector.detect(picked.image);
          reading = null;
        case ScanKind.textRecognition:
          reading = await reader.read(picked);
          detections = const [];
      }
      final currentReading = reading;
      final summary = switch (kind) {
        ScanKind.objectDetection => summarizeDetections(detections),
        ScanKind.textRecognition => summarizeText(currentReading?.text ?? ''),
      };
      final id = _idFactory();
      final entry = HistoryEntry(
        id: id,
        createdAt: _clock(),
        kind: kind,
        summary: summary,
        imageWidth: picked.image.width,
        imageHeight: picked.image.height,
        imagePath: await imageStore.persist(picked, id),
        detections: detections,
        recognizedText: currentReading?.text ?? '',
        textRegions: currentReading?.regions ?? const [],
      );
      await history.save(entry);
      saved = entry;
      phase = ScanPhase.result;
    } on DetectionException catch (error) {
      errorMessage = error.message;
      modelMissing = error.modelMissing;
      phase = ScanPhase.failed;
    } on FormatException catch (error) {
      errorMessage = error.message;
      phase = ScanPhase.failed;
    } on Object catch (error) {
      errorMessage = 'This scan could not be finished. $error';
      phase = ScanPhase.failed;
    }
    notifyListeners();
  }
}
