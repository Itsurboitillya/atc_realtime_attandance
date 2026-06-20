import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/session.dart';

class SessionService extends ChangeNotifier {
  static const _kStorageKey = 'attendance_sessions_v1';
  List<Session> _sessions = [];

  List<Session> get sessions => List.unmodifiable(_sessions);

  SessionService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStorageKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _sessions = list
            .map((e) => Session.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {
        _sessions = [];
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_kStorageKey, raw);
  }

  Future<void> add(Session s) async {
    _sessions.insert(0, s);
    await _save();
    notifyListeners();
  }

  Future<void> update(Session s) async {
    final idx = _sessions.indexWhere((e) => e.id == s.id);
    if (idx != -1) {
      _sessions[idx] = s;
      await _save();
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    _sessions.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  Session? byId(String id) {
    try {
      return _sessions.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
