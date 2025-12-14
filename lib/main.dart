import 'package:flutter/material.dart';
import 'package:si_absen/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: 'https://asexskflmsgvyzxgiips.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzZXhza2ZsbXNndnl6eGdpaXBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxNTY3NzMsImV4cCI6MjA3NzczMjc3M30.FrKnH-XztmNprq3kesskvTMtWzuyEduNsFEM9g1MmR0',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SI Absen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}