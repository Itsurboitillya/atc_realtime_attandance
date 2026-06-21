import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ConnectionStatus { checking, connected, disconnected }

class SupabaseConnectionService extends ChangeNotifier {
  ConnectionStatus _status = ConnectionStatus.checking;
  bool _isSendingData = false;
  String _lastError = '';
  final SupabaseClient _supabase;

  SupabaseConnectionService(this._supabase) {
    _initConnection();
  }

  ConnectionStatus get status => _status;
  bool get isSendingData => _isSendingData;
  String get lastError => _lastError;

  Future<void> _initConnection() async {
    await checkConnection();
  }

  Future<void> checkConnection() async {
    _status = ConnectionStatus.checking;
    notifyListeners();

    try {
      // Test connection by trying to fetch user info
      final user = _supabase.auth.currentUser;
      
      if (user != null) {
        // Verify connection by making a simple query
        await _supabase
            .from('attendance_records')
            .select()
            .limit(1);
        
        _status = ConnectionStatus.connected;
        _lastError = '';
      } else {
        _status = ConnectionStatus.disconnected;
        _lastError = 'Not authenticated';
      }
    } catch (e) {
      _status = ConnectionStatus.disconnected;
      _lastError = e.toString();
      if (kDebugMode) {
        print('Supabase connection error: $e');
      }
    }

    notifyListeners();
  }

  Future<void> sendDataToSupabase(
      {required String table,
      required Map<String, dynamic> data}) async {
    _isSendingData = true;
    notifyListeners();

    try {
      await _supabase.from(table).insert(data);
      _lastError = '';
    } catch (e) {
      _lastError = 'Failed to send data: $e';
      if (kDebugMode) {
        print('Error sending data: $e');
      }
    } finally {
      _isSendingData = false;
      notifyListeners();
    }
  }

  Color getStatusColor() {
    switch (_status) {
      case ConnectionStatus.connected:
        return const Color(0xFF4CAF50); // Green
      case ConnectionStatus.checking:
        return const Color(0xFFFFC107); // Amber
      case ConnectionStatus.disconnected:
        return const Color(0xFFF44336); // Red
    }
  }

  String getStatusText() {
    switch (_status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.checking:
        return 'Checking...';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
    }
  }
}
