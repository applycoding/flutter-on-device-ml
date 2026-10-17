import 'package:flutter/material.dart';

import 'package:flutter_on_device_ml/src/history/history_entry.dart';
import 'package:flutter_on_device_ml/src/imaging/image_gateway.dart';
import 'package:flutter_on_device_ml/src/ui/detection_overlay.dart';
import 'package:flutter_on_device_ml/src/ui/guide_page.dart';
import 'package:flutter_on_device_ml/src/ui/latency_table.dart';
import 'package:flutter_on_device_ml/src/ui/scan_session.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, required this.session, this.autostart = false});

  final ScanSession session;
  final bool autostart;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSession);
    if (widget.autostart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.session.pick(ImageOrigin.gallery);
      });
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSession);
    super.dispose();
  }

  void _onSession() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final title = switch (session.kind) {
      ScanKind.objectDetection => 'Detect objects',
      ScanKind.textRecognition => 'Read text',
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                switch (session.phase) {
                  ScanPhase.chooseSource => _ChooseSource(session: session),
                  ScanPhase.running => const _Running(),
                  ScanPhase.result => _Result(session: session),
                  ScanPhase.failed => _Failed(session: session),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChooseSource extends StatelessWidget {
  const _ChooseSource({required this.session});

  final ScanSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose a photo. The result stays on this phone.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('pick-camera'),
          onPressed: () => session.pick(ImageOrigin.camera),
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Camera'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('pick-gallery'),
          onPressed: () => session.pick(ImageOrigin.gallery),
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Gallery'),
        ),
      ],
    );
  }
}

class _Running extends StatelessWidget {
  const _Running();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Running on this phone'),
        ],
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.session});

  final ScanSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photo = session.photo;
    final reading = session.reading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (photo != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DetectionOverlay(
              imageWidth: photo.image.width,
              imageHeight: photo.image.height,
              pixels: photo.image,
              detections: session.detections,
              regions: reading?.regions ?? const [],
            ),
          ),
        const SizedBox(height: 16),
        Text(
          session.saved?.summary ?? '',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (session.kind == ScanKind.objectDetection) ...[
          if (session.detections.isEmpty)
            const Text('No objects above the score threshold.')
          else
            for (var i = 0; i < session.detections.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                key: ValueKey('detection-$i'),
                title: Text(session.detections[i].label),
                subtitle: const Text('Model score for this image'),
                trailing: Text(session.detections[i].score.toStringAsFixed(2)),
              ),
        ],
        if (session.kind == ScanKind.textRecognition) ...[
          SelectableText(
            reading?.text.isEmpty ?? true
                ? 'No text recognized'
                : reading!.text,
            key: const Key('recognized-text'),
            style: theme.textTheme.bodyLarge,
          ),
          for (var i = 0; i < (reading?.regions.length ?? 0); i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(reading!.regions[i].text),
            ),
        ],
        const SizedBox(height: 8),
        const LatencyTable(),
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('scan-again'),
          onPressed: () => session.pick(ImageOrigin.gallery),
          child: const Text('Choose from the gallery'),
        ),
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.session});

  final ScanSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.error_outline, color: theme.colorScheme.error, size: 36),
        const SizedBox(height: 12),
        Text(
          session.errorMessage ?? 'This scan could not be finished.',
          key: const Key('scan-error'),
        ),
        const SizedBox(height: 16),
        if (session.modelMissing)
          FilledButton(
            key: const Key('model-missing'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const GuidePage()),
              );
            },
            child: const Text('Model setup'),
          ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => session.pick(ImageOrigin.gallery),
          child: const Text('Try another photo'),
        ),
      ],
    );
  }
}
