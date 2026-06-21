import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session.dart';
import '../models/student_attendance.dart';
import '../services/student_service.dart';

/// This screen shows a simple real-time attendance monitor.
/// It includes a "Simulate join" button for local testing.
class AttendanceMonitorScreen extends StatefulWidget {
  final Session session;
  const AttendanceMonitorScreen({super.key, required this.session});

  @override
  State<AttendanceMonitorScreen> createState() => _AttendanceMonitorScreenState();
}

class _AttendanceMonitorScreenState extends State<AttendanceMonitorScreen> {
  final List<StudentAttendance> _attendance = [];
  final StreamController<List<StudentAttendance>> _stream = StreamController.broadcast();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  @override
  void dispose() {
    _stream.close();
    super.dispose();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    final service = Provider.of<StudentService>(context, listen: false);
    final records = await service.fetchAttendanceForSession(widget.session.id);
    if (!mounted) return;
    _attendance
      ..clear()
      ..addAll(records);
    _stream.add(List.unmodifiable(_attendance));
    setState(() => _isLoading = false);
  }

  void _simulateJoin() {
    final attendance = StudentAttendance(
      id: 'local-${_attendance.length + 1}',
      sessionId: widget.session.id,
      studentName: 'Student ${_attendance.length + 1}',
      admissionNumber: 'SIM${_attendance.length + 1}',
      timestamp: DateTime.now().toIso8601String(),
      moduleName: widget.session.moduleName,
    );
    _attendance.add(attendance);
    _stream.add(List.unmodifiable(_attendance));
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
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: StreamBuilder<List<StudentAttendance>>(
                  stream: _stream.stream,
                  initialData: List.unmodifiable(_attendance),
                  builder: (context, snap) {
                    final list = snap.data ?? [];
                    if (list.isEmpty) return const Center(child: Text('No students yet'));
                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (ctx, i) {
                        final attendance = list[i];
                        return ListTile(
                          title: Text(attendance.studentName),
                          subtitle: Text('${attendance.admissionNumber} • ${attendance.moduleName}'),
                          trailing: Text(attendance.timestamp.split('T').first),
                        );
                      },
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
                      _attendance.clear();
                      _stream.add(List.unmodifiable(_attendance));
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _loadAttendance,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Note: Attendance records are loaded from Supabase and refreshed on demand.'),
          ],
        ),
      ),
    );
  }
}
