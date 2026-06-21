import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/session.dart' as session_model;

class SessionService extends ChangeNotifier {
  static const _kStorageKey = 'attendance_sessions_v1';
  List<session_model.Session> _sessions = [];
  final SupabaseClient _supabase = Supabase.instance.client;

  List<session_model.Session> get sessions => List.unmodifiable(_sessions);

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
            .map((e) => session_model.Session.fromJson(Map<String, dynamic>.from(e)))
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

  Future<void> add(session_model.Session s) async {
    _sessions.insert(0, s);
    await _save();
    notifyListeners();
    
    // Sync to Supabase in background
    try {
      await _supabase.from('sessions').insert({
        'id': s.id,
        'name': s.name,
        'number_of_students': s.numberOfStudents,
        'date': s.date,
        'level': s.level,
        'module_name': s.moduleName,
        'qr_url': s.url,
        'timer_minutes': s.timerMinutes,
        'created_at': s.createdAt,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing session to Supabase: $e');
      }
    }
  }

  Future<void> update(session_model.Session s) async {
    final idx = _sessions.indexWhere((e) => e.id == s.id);
    if (idx != -1) {
      _sessions[idx] = s;
      await _save();
      notifyListeners();
      
      // Sync to Supabase in background
      try {
        await _supabase.from('sessions').update({
          'name': s.name,
          'number_of_students': s.numberOfStudents,
          'date': s.date,
          'level': s.level,
          'module_name': s.moduleName,
          'qr_url': s.url,
          'timer_minutes': s.timerMinutes,
        }).eq('id', s.id);
      } catch (e) {
        if (kDebugMode) {
          print('Error updating session in Supabase: $e');
        }
      }
    }
  }

  Future<void> remove(String id) async {
    _sessions.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
    
    // Sync to Supabase in background
    try {
      await _supabase.from('sessions').delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting session from Supabase: $e');
      }
    }
  }

  session_model.Session? byId(String id) {
    try {
      return _sessions.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
