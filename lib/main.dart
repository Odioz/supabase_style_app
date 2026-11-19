import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'design/theme.dart';
import 'screens/home_screen.dart';
// import 'screens/login_screen.dart'; // если хочешь оставить авторизацию

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://locdjzuulxtekfjjsshl.supabase.co',
    publishableKey: '',
  );

  runApp(const PojarkaApp());
}

class PojarkaApp extends StatelessWidget {
  const PojarkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Пожарка',
      debugShowCheckedModeBanner: false,  
      theme: SupabaseTheme.dark,
      home: const HomeScreen(), // без авторизации — сразу к подразделениям
    );
  }
}