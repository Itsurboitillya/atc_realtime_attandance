import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'submission_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller =
      MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool _scanned = false;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) {
    if (_scanned) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final raw = barcode.rawValue ?? '';
    if (raw.isEmpty) return;

    try {
      final payload = jsonDecode(raw) as Map<String, dynamic>;
      _scanned = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SubmissionScreen(payload: payload)),
      );
    } catch (_) {
      setState(() {
        _message = 'Invalid QR code. Please scan a valid attendance QR.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Session QR'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _handleDetection,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Point the camera at the session QR code.',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                if (_message != null)
                  Text(
                    _message!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _controller.toggleTorch(),
                        icon: const Icon(Icons.flash_on),
                        label: const Text('Flash'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _controller.switchCamera(),
                        icon: const Icon(Icons.flip_camera_android),
                        label: const Text('Flip'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
