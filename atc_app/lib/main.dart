import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'services/auth_service.dart';
import 'services/session_service.dart';
import 'services/student_service.dart';
import 'services/supabase_connection_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/student_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SessionService()),
        ChangeNotifierProvider(create: (_) => StudentService()),
        ChangeNotifierProvider(
          create: (_) => SupabaseConnectionService(Supabase.instance.client),
        ),
      ],
      child: MaterialApp(
        title: 'Attendance QR',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthScreen(),
      ),
    );
  }
}
