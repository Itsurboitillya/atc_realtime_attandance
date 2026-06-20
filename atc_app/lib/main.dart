import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/session_service.dart';
import 'services/student_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/student_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionService()),
        ChangeNotifierProvider(create: (_) => StudentService()),
      ],
      child: MaterialApp(
        title: 'Attendance QR',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (ctx) => const LoginScreen(),
          '/role': (ctx) => const RoleSelectionScreen(),
          '/home': (ctx) => const HomeScreen(),
          '/student': (ctx) => const StudentDashboardScreen(),
        },
      ),
    );
  }
}
