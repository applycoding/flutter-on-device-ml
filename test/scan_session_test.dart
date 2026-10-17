import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_on_device_ml/src/detection/detection_box.dart';
import 'package:flutter_on_device_ml/src/detection/detection_exception.dart';
import 'package:flutter_on_device_ml/src/history/history_entry.dart';
import 'package:flutter_on_device_ml/src/imaging/image_gateway.dart';
import 'package:flutter_on_device_ml/src/ocr/text_read.dart';
import 'package:flutter_on_device_ml/src/ui/scan_session.dart';
import 'support/fakes.dart';

void main() {
  test('memory history returns newest first and drops a deleted id', () async {
    final history = MemoryHistoryRepository();
    final older = _entry('a', 'cup');
    final newer = _entry('b', 'book');
    await history.save(older);
    await history.save(newer);

    expect((await history.loadAll()).map((item) => item.id), ['b', 'a']);
    await history.delete('b');
    expect((await history.loadAll()).single.id, 'a');
  });

  test('history details round-trip boxes and text', () {
    final entry = _entry('a', 'cup').fromStorageRoundTrip();
    expect(entry.detections.single.label, 'cup');
    expect(entry.detections.single.score, 0.91);
    expect(entry.recognizedText, 'Cafe');
    expect(entry.textRegions.single.text, 'Cafe');
    expect(entry.kind, ScanKind.objectDetection);
  });

  test('a detection scan saves one history row and skips a cancelled pick', () async {
    final history = MemoryHistoryRepository();
    final images = FakeImageGateway(samplePick());
    final detector = FakeObjectDetector(
      detections: const [
        DetectionBox(
          left: 1,
          top: 0,
          right: 3,
          bottom: 2,
          score: 0.91,
          classId: 41,
          label: 'cup',
        ),
      ],
    );
    final session = ScanSession(
      kind: ScanKind.objectDetection,
      detector: detector,
      reader: FakeTextReader(),
      images: images,
      history: history,
      imageStore: MemoryImageStore(),
      clock: () => DateTime.utc(2026, 10, 17, 12),
      idFactory: () => 'scan-1',
    );

    await session.pick(ImageOrigin.gallery);

    expect(session.phase, ScanPhase.result);
    expect(session.saved?.summary, 'cup');
    expect(session.saved?.createdAt, DateTime.utc(2026, 10, 17, 12));
    expect(detector.detectCalls, 1);
    expect(images.lastOrigin, ImageOrigin.gallery);
    expect((await history.loadAll()).single.summary, 'cup');

    images.photo = null;
    await session.pick(ImageOrigin.camera);
    expect(session.phase, ScanPhase.chooseSource);
    expect(detector.detectCalls, 1);
    expect((await history.loadAll()), hasLength(1));
    session.dispose();
  });

  test('a missing model is reported and is not stored', () async {
    final history = MemoryHistoryRepository();
    final session = ScanSession(
      kind: ScanKind.objectDetection,
      detector: FakeObjectDetector(
        error: const DetectionException(
          'No detection model is installed.',
          modelMissing: true,
        ),
      ),
      reader: FakeTextReader(),
      images: FakeImageGateway(samplePick()),
      history: history,
      imageStore: MemoryImageStore(),
    );

    await session.pick(ImageOrigin.gallery);

    expect(session.phase, ScanPhase.failed);
    expect(session.modelMissing, isTrue);
    expect(await history.loadAll(), isEmpty);
    session.dispose();
  });

  test('text recognition stores the recognized line', () async {
    final history = MemoryHistoryRepository();
    final session = ScanSession(
      kind: ScanKind.textRecognition,
      detector: FakeObjectDetector(),
      reader: FakeTextReader(
        reading: const TextRead(
          text: 'Cafe Nero',
          regions: [
            TextRegion(text: 'Cafe Nero', left: 0, top: 0, right: 4, bottom: 1),
          ],
        ),
      ),
      images: FakeImageGateway(samplePick()),
      history: history,
      imageStore: MemoryImageStore(),
      idFactory: () => 'text-1',
    );

    await session.pick(ImageOrigin.camera);

    expect(session.phase, ScanPhase.result);
    expect(session.saved?.summary, 'Cafe Nero');
    expect((await history.loadAll()).single.recognizedText, 'Cafe Nero');
    session.dispose();
  });
}

HistoryEntry _entry(String id, String label) {
  return HistoryEntry(
    id: id,
    createdAt: DateTime.utc(2026, 10, 17, 12),
    kind: ScanKind.objectDetection,
    summary: label,
    imageWidth: 4,
    imageHeight: 2,
    detections: [
      DetectionBox(
        left: 0,
        top: 0,
        right: 2,
        bottom: 2,
        score: 0.91,
        classId: 1,
        label: label,
      ),
    ],
    recognizedText: 'Cafe',
    textRegions: const [
      TextRegion(text: 'Cafe', left: 0, top: 0, right: 1, bottom: 1),
    ],
  );
}

extension on HistoryEntry {
  HistoryEntry fromStorageRoundTrip() {
    return HistoryEntry.fromStorage(
      id: id,
      createdAt: createdAt,
      kindName: kind.name,
      summary: summary,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      imagePath: imagePath,
      detailsJson: detailsJson,
    );
  }
}
