import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  bool isLoading = false;
  bool isAdmin = false;
  String? role;
  String? email;
  String? errorMessage;

  AuthService() {
    _loadCurrentUser();
  }

  bool get isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  Future<void> _loadCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      email = user.email;
      final metadata = user.userMetadata;
      if (metadata is Map<String, dynamic>) {
        role = metadata['role'] as String?;
      }
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'role': role},
      );

      if (response.user == null && response.session == null) {
        // If signup succeeded but no session was returned, try a login immediately.
        final loginResponse = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (loginResponse.user == null && loginResponse.session == null) {
          errorMessage = 'Unable to sign in after signup';
          return false;
        }
        _setUser(loginResponse.user);
      } else {
        _setUser(response.user);
      }

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null && response.session == null) {
        errorMessage = 'Login failed';
        return false;
      }

      _setUser(response.user);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    role = null;
    email = null;
    isAdmin = false;
    errorMessage = null;
    notifyListeners();
  }

  void _setUser(User? user) {
    if (user == null) return;
    email = user.email;
    final metadata = user.userMetadata;
    if (metadata is Map<String, dynamic>) {
      role = metadata['role'] as String?;
    }
  }

  bool checkAdminPassword(String password) {
    return password == '0987654321';
  }
}
