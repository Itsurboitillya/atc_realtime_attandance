import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/session.dart';
import 'attendance_monitor_screen.dart';

class SessionQrScreen extends StatelessWidget {
  final Session session;
  const SessionQrScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final payload = jsonEncode({
      'sessionId': session.id,
      'name': session.name,
      'module': session.moduleName,
      'date': session.date,
      'url': session.url,
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Session QR')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(session.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            QrImageView(data: payload, size: 260),
            const SizedBox(height: 12),
            Text('Scan this QR code with the student app or scanner to record attendance.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AttendanceMonitorScreen(session: session)),
              ),
              child: const Text('Open Attendance Monitor'),
            ),
          ],
        ),
      ),
    );
  }
}
