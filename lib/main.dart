import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://onadjyvncpqepgvvztnb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9uYWRqeXZuY3BxZXBndnZ6dG5iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY4NzAxNjIsImV4cCI6MjA5MjQ0NjE2Mn0.OW9LMX0gzm-XRTetYUNFppzA2A7e19jl14VES0duxl8',
  );

  runApp(const CampusPrintApp());
}

class CampusPrintApp extends StatelessWidget {
  const CampusPrintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Print',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
hjgxygyuxgyuxgyu