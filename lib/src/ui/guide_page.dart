import 'package:flutter/material.dart';

import 'package:flutter_on_device_ml/src/ui/latency_table.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Model setup')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              key: const Key('model-guide'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Text(
                  'Weights are not in this repository. Download one of the public models below, then point the app at the file. Both archives are TensorFlow models under the Apache License 2.0.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                const _Section(
                  title: 'SSD MobileNet, quantized',
                  body:
                      '300×300 COCO checkpoint from 29 June 2018. The zip contains detect.tflite and labelmap.txt. The label map shipped with this app is that labelmap.txt: line index equals the class id, including the ??? placeholders. classIndexBase stays 0.',
                ),
                const _Command(
                  'curl -L -o /tmp/coco_ssd_mobilenet.zip \\\n'
                  '  https://storage.googleapis.com/download.tensorflow.org/models/tflite/coco_ssd_mobilenet_v1_1.0_quant_2018_06_29.zip\n'
                  'unzip -p /tmp/coco_ssd_mobilenet.zip detect.tflite > assets/models/detect.tflite',
                ),
                const SizedBox(height: 20),
                const _Section(
                  title: 'EfficientDet-Lite0',
                  body:
                      '320×320 detection model from the TensorFlow Lite task library, with detection post-processing. After download, set inputWidth and inputHeight to 320 in assets/models/model_config.json. If labels are shifted by one, change classIndexBase. The interpreter still reads the input tensor size from the file.',
                ),
                const _Command(
                  'curl -L -o assets/models/detect.tflite \\\n'
                  '  https://storage.googleapis.com/download.tensorflow.org/models/tflite/task_library/object_detection/android/lite-model_efficientdet_lite0_detection_metadata_1.tflite',
                ),
                const SizedBox(height: 20),
                const _Section(
                  title: 'License',
                  body:
                      'Apache License 2.0. The TensorFlow models license is at https://github.com/tensorflow/models/blob/master/LICENSE and the license text is at https://www.apache.org/licenses/LICENSE-2.0. This app does not redistribute the weights. Confirm the license again before you ship a model.',
                ),
                const SizedBox(height: 20),
                const _Section(
                  title: 'Install the file',
                  body:
                      'Put detect.tflite in assets/models/, add it under flutter: assets: in pubspec.yaml, and rebuild. The file is gitignored. A copy in the application support directory models/detect.tflite is used first, which is how a debug Android build can sideload without a rebuild:',
                ),
                const _Command(
                  'adb push detect.tflite /data/local/tmp/detect.tflite\n'
                  'adb shell run-as dev.arpanbom.stillframe.flutter_on_device_ml mkdir -p files/models\n'
                  'adb shell run-as dev.arpanbom.stillframe.flutter_on_device_ml cp /data/local/tmp/detect.tflite files/models/detect.tflite',
                ),
                const SizedBox(height: 20),
                const _Section(
                  title: 'What the graph must look like',
                  body:
                      'The detector reads a float32 post-processed output: boxes, classes, scores, and usually a count. Boxes default to normalized ymin, xmin, ymax, xmax. Letterboxing keeps aspect ratio and maps boxes back to the photo. NMS runs again unless applyNms is false. A graph without that layout fails with an error instead of inventing boxes. The CPU interpreter is used. GPU and NNAPI delegates are off.',
                ),
                const SizedBox(height: 12),
                Text(
                  'Text recognition uses the bundled Latin ML Kit model. It does not call a cloud vision API. ML Kit is Android and iOS only.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                const LatencyTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(body),
      ],
    );
  }
}

class _Command extends StatelessWidget {
  const _Command(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SelectableText(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
