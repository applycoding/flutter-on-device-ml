import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_on_device_ml/app.dart';
import 'package:flutter_on_device_ml/src/detection/detection_box.dart';
import 'package:flutter_on_device_ml/src/detection/detection_exception.dart';
import 'package:flutter_on_device_ml/src/history/history_entry.dart';
import 'package:flutter_on_device_ml/src/imaging/image_gateway.dart';
import 'package:flutter_on_device_ml/src/ocr/text_read.dart';
import 'package:flutter_on_device_ml/src/ui/detection_overlay.dart';
import 'support/fakes.dart';

void main() {
  testWidgets('detection flow paints boxes and keeps history', (tester) async {
    final history = MemoryHistoryRepository();
    final images = FakeImageGateway(samplePick());
    await _pump(
      tester,
      history: history,
      images: images,
      detector: FakeObjectDetector(
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
      ),
    );

    expect(find.byKey(const Key('empty-history')), findsOneWidget);
    expect(find.text('Detection model found on this phone.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('detect-objects')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-gallery')));
    await tester.pumpAndSettle();

    expect(images.lastOrigin, ImageOrigin.gallery);
    expect(find.text('cup'), findsWidgets);
    expect(find.byKey(const Key('detection-overlay')), findsOneWidget);
    expect(find.byType(DetectionOverlay), findsOneWidget);
    expect(find.text('placeholder'), findsWidgets);
    expect(
      find.text('These cells are placeholders. Nothing here has been measured.'),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('cup'), findsOneWidget);
    expect(find.byKey(const Key('empty-history')), findsNothing);
    expect((await history.loadAll()).single.summary, 'cup');
  });

  testWidgets('text recognition shows the fake reading', (tester) async {
    await _pump(
      tester,
      reader: FakeTextReader(
        reading: const TextRead(
          text: 'Cafe Nero',
          regions: [
            TextRegion(text: 'Cafe Nero', left: 0, top: 0, right: 4, bottom: 1),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('read-text')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-camera')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('recognized-text')), findsOneWidget);
    expect(find.text('Cafe Nero'), findsWidgets);
  });

  testWidgets('a cancelled pick stays on the chooser', (tester) async {
    await _pump(tester, images: FakeImageGateway(null));

    await tester.tap(find.byKey(const Key('detect-objects')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-gallery')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pick-camera')), findsOneWidget);
    expect(find.byKey(const Key('scan-error')), findsNothing);
  });

  testWidgets('a missing model shows setup instead of boxes', (tester) async {
    await _pump(
      tester,
      detector: FakeObjectDetector(
        ready: false,
        error: const DetectionException(
          'No detection model is installed.',
          modelMissing: true,
        ),
      ),
    );

    expect(find.text('Detection model not installed.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('detect-objects')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-gallery')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('scan-error')), findsOneWidget);
    expect(find.byKey(const Key('model-missing')), findsOneWidget);
    expect(find.text('No detection model is installed.'), findsWidgets);

    await tester.tap(find.byKey(const Key('model-missing')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Apache License 2.0'), findsWidgets);
  });

  testWidgets('history can be opened and deleted', (tester) async {
    final history = MemoryHistoryRepository();
    await history.save(
      HistoryEntry(
        id: 'saved-1',
        createdAt: DateTime.utc(2026, 10, 17, 15),
        kind: ScanKind.objectDetection,
        summary: 'book',
        imageWidth: 4,
        imageHeight: 2,
        detections: const [
          DetectionBox(
            left: 0,
            top: 0,
            right: 2,
            bottom: 2,
            score: 0.5,
            classId: 2,
            label: 'book',
          ),
        ],
        recognizedText: '',
        textRegions: const [],
      ),
    );
    await _pump(tester, history: history);

    expect(find.text('book'), findsOneWidget);
    await tester.tap(find.byKey(const Key('open-history')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('history-saved-1')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('delete-saved-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('empty-history')), findsOneWidget);
    expect(await history.loadAll(), isEmpty);
  });

  testWidgets('model setup documents the placeholder latency table', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pump(tester);
    await tester.tap(find.byKey(const Key('open-guide')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Apache License 2.0'), findsWidgets);
    expect(find.textContaining('coco_ssd_mobilenet_v1'), findsOneWidget);
    expect(find.textContaining('efficientdet_lite0'), findsOneWidget);
    expect(find.byKey(const Key('latency-table')), findsOneWidget);
    expect(find.text('placeholder'), findsNWidgets(4));
  });
}

Future<void> _pump(
  WidgetTester tester, {
  FakeObjectDetector? detector,
  FakeTextReader? reader,
  ImageGateway? images,
  HistoryRepository? history,
}) async {
  await tester.pumpWidget(
    StillframeApp(
      detector: detector ?? FakeObjectDetector(),
      reader: reader ?? FakeTextReader(),
      images: images ?? FakeImageGateway(samplePick()),
      history: history ?? MemoryHistoryRepository(),
      imageStore: MemoryImageStore(),
    ),
  );
  await tester.pumpAndSettle();
}
