import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/supabase_connection_service.dart';
import 'home_screen.dart';
import 'student_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String _mode = 'login';
  String _role = 'student';
  int _teacherTapCount = 0;

  void _toggleMode() {
    setState(() {
      _mode = _mode == 'login' ? 'signup' : 'login';
    });
  }

  Future<void> _submit(AuthService authService) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool success = false;

    if (_mode == 'signup') {
      success = await authService.signUp(email: email, password: password, role: _role);
    } else {
      success = await authService.signIn(email: email, password: password);
    }

    if (!mounted) return;

    if (success) {
      final role = authService.role;
      if (authService.isAdmin) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        return;
      }
      if (role == 'teacher') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else if (role == 'student') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentDashboardScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In / Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 12),
              if (_mode == 'signup')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create an account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('Select your role'),
                    const SizedBox(height: 8),
                    ToggleButtons(
                      isSelected: [_role == 'teacher', _role == 'student'],
                      onPressed: (index) {
                        setState(() {
                          _role = index == 0 ? 'teacher' : 'student';
                        });
                      },
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Teacher')),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Student')),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email';
                  if (!value.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter password';
                  if (value.length < 6) return 'Use 6+ characters';
                  return null;
                },
              ),
              if (_mode == 'signup')
                Column(
                  children: [
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmController,
                      decoration: const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Confirm password';
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authService.isLoading ? null : () => _submit(authService),
                child: Text(authService.isLoading ? 'Please wait...' : _mode == 'signup' ? 'Create Account' : 'Login'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: authService.isLoading ? null : _toggleMode,
                child: Text(_mode == 'signup' ? 'Have an account? Login' : 'Need an account? Sign up'),
              ),
              if (authService.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(authService.errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _teacherTapCount += 1;
                    if (_teacherTapCount >= 20) {
                      _teacherTapCount = 0;
                      _showAdminLogin();
                    }
                  });
                },
                child: const Text('Teacher'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _mode = 'login';
                  });
                  _emailController.text = '';
                  _passwordController.text = '';
                  _confirmController.text = '';
                },
                child: const Text('Student'),
              ),
              const SizedBox(height: 12),
              Consumer<SupabaseConnectionService>(
                builder: (context, connectionService, _) {
                  final status = connectionService.getStatusText();
                  return Text('Supabase status: $status');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdminLogin() {
    showDialog(
      context: context,
      builder: (context) {
        final _adminController = TextEditingController();
        return AlertDialog(
          title: const Text('Admin Login'),
          content: TextField(
            controller: _adminController,
            decoration: const InputDecoration(labelText: 'Admin password'),
            obscureText: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final authService = Provider.of<AuthService>(context, listen: false);
                if (authService.checkAdminPassword(_adminController.text.trim())) {
                  authService.isAdmin = true;
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text('Enter'),
            ),
          ],
        );
      },
    );
  }
}
