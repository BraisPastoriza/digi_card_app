import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../l10n/l10n.dart';

/// Opens the camera and returns the text of the first QR code it sees, or
/// null if the user backs out.
Future<String?> scanDeckQr(BuildContext context) => Navigator.of(
  context,
).push<String>(MaterialPageRoute(builder: (_) => const _QrScanScreen()));

/// Reads a QR code out of a picture the user picks — a code someone sent as a
/// screenshot, which is how most of them travel.
///
/// Returns null when the user picks nothing, and throws [FormatException] when
/// the picture has no code in it.
Future<String?> readDeckQrFromImage() async {
  final file = await FilePicker.pickFile(type: FileType.image);
  if (file == null) return null;

  // The scanner reads from a path, and what the system picker hands back is
  // usually a content URI with none. A copy in the cache always has one.
  var path = file.path;
  File? copy;
  if (path == null) {
    copy = File(
      p.join((await getTemporaryDirectory()).path, 'qr-${file.name}'),
    );
    await copy.writeAsBytes(await file.readAsBytes());
    path = copy.path;
  }

  final controller = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  try {
    final capture = await controller.analyzeImage(
      path,
      formats: [BarcodeFormat.qrCode],
    );
    final text = capture?.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (text == null || text.trim().isEmpty) {
      throw const FormatException('No QR code in the picture');
    }
    return text;
  } finally {
    await controller.dispose();
    if (copy != null && await copy.exists()) await copy.delete();
  }
}

class _QrScanScreen extends StatefulWidget {
  const _QrScanScreen();

  @override
  State<_QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<_QrScanScreen> {
  final _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  /// Set once a code is taken, so a second frame of the same code cannot pop
  /// the screen twice.
  var _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    final text = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .firstOrNull;
    if (text == null) return;
    _done = true;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.qrScanTitle),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  error.errorCode == MobileScannerErrorCode.permissionDenied
                      ? l10n.qrScanNoPermission
                      : l10n.qrScanUnavailable,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, height: 1.45),
                ),
              ),
            ),
          ),
          // A frame to aim with, and what to do with it — both gone when the
          // camera is not there, where they would sit on top of the message
          // saying why.
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.error != null) return const SizedBox.shrink();
              return Stack(
                fit: StackFit.expand,
                children: [
                  // The scanner reads the whole picture, but a square tells
                  // the user how close to hold the phone.
                  IgnorePointer(
                    child: Center(
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 48,
                    child: Text(
                      l10n.qrScanHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, height: 1.45),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
