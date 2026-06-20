import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_attendance.dart';

class StudentService extends ChangeNotifier {
  static const _kKey = 'student_attendance_v1';
  List<StudentAttendance> _entries = [];

  StudentService() {
    _load();
  }

  List<StudentAttendance> get entries => List.unmodifiable(_entries);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _entries = list
            .map(
                (e) => StudentAttendance.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {
        _entries = [];
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_kKey, raw);
  }

  Future<StudentAttendance> addAttendance(
      {required String sessionId,
      required String studentName,
      required String admissionNumber,
      required String moduleName}) async {
    final entry = StudentAttendance(
      id: const Uuid().v4(),
      sessionId: sessionId,
      studentName: studentName,
      admissionNumber: admissionNumber,
      timestamp: DateTime.now().toIso8601String(),
      moduleName: moduleName,
    );
    _entries.insert(0, entry);
    await _save();
    notifyListeners();
    return entry;
  }

  List<StudentAttendance> forSession(String sessionId) =>
      _entries.where((e) => e.sessionId == sessionId).toList();

  List<StudentAttendance> forStudent(String admissionNumber) =>
      _entries.where((e) => e.admissionNumber == admissionNumber).toList();

  Future<String> exportCsvForSession(String sessionId) async {
    final list = forSession(sessionId);
    final rows = <List<String>>[];
    rows.add(['AdmissionNumber', 'StudentName', 'Module', 'Timestamp']);
    for (final e in list) {
      rows.add([e.admissionNumber, e.studentName, e.moduleName, e.timestamp]);
    }
    final csv = rows
        .map((r) => r.map((c) => '"${c.replaceAll('"', '""')}"').join(','))
        .join('\n');
    return csv;
  }
}
