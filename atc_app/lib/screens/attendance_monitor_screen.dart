import 'dart:async';
import 'package:flutter/material.dart';

import '../models/session.dart';

/// This screen shows a simple real-time attendance monitor.
/// It includes a "Simulate join" button for local testing.
class AttendanceMonitorScreen extends StatefulWidget {
  final Session session;
  const AttendanceMonitorScreen({super.key, required this.session});

  @override
  State<AttendanceMonitorScreen> createState() => _AttendanceMonitorScreenState();
}

class _AttendanceMonitorScreenState extends State<AttendanceMonitorScreen> {
  final List<String> _joined = [];
  final StreamController<List<String>> _stream = StreamController.broadcast();

  @override
  void dispose() {
    _stream.close();
    super.dispose();
  }

  void _simulateJoin() {
    final name = 'Student ${_joined.length + 1}';
    _joined.add(name);
    _stream.add(List.unmodifiable(_joined));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Monitor')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.session.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Module: ${widget.session.moduleName} • Date: ${widget.session.date}'),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: _stream.stream,
                initialData: List.unmodifiable(_joined),
                builder: (context, snap) {
                  final list = snap.data ?? [];
                  if (list.isEmpty) return const Center(child: Text('No students yet'));
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (ctx, i) => ListTile(title: Text(list[i])),
                  );
                },
              ),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _simulateJoin,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Simulate Join'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _joined.clear();
                      _stream.add(List.unmodifiable(_joined));
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Note: For real-time attendance across devices, integrate a backend (Firebase Realtime/Firestore or WebSocket).'),
          ],
        ),
      ),
    );
  }
}
