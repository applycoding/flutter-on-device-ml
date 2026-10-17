import 'package:flutter/widgets.dart';

import 'package:flutter_on_device_ml/app.dart';
import 'package:flutter_on_device_ml/src/detection/tflite_object_detector.dart';
import 'package:flutter_on_device_ml/src/history/drift_history_repository.dart';
import 'package:flutter_on_device_ml/src/history/history_database.dart';
import 'package:flutter_on_device_ml/src/imaging/picker_image_gateway.dart';
import 'package:flutter_on_device_ml/src/ocr/mlkit_text_reader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = HistoryDatabase.defaults();
  runApp(
    StillframeApp(
      detector: TfliteObjectDetector(),
      reader: MlkitTextReader(),
      images: PickerImageGateway(),
      history: DriftHistoryRepository(database),
      imageStore: FileImageStore(),
    ),
  );
}
