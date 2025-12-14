// lib/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:si_absen/beranda_admin.dart';
import 'package:si_absen/beranda_guru.dart';
import 'package:si_absen/laporan_ortu.dart'; // Tambahkan import ini
import 'package:si_absen/selamat_datang.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isGuruLoggedIn = prefs.getBool('is_guru_logged_in') ?? false;
    final isOrtuLoggedIn = prefs.getBool('is_ortu_logged_in') ?? false; // Tambahkan ini
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      if (isGuruLoggedIn) {
        // Jika guru login -> ke Beranda Guru
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (isOrtuLoggedIn) {
        // Jika ortu login -> ke Laporan Ortu
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LaporanOrtuScreen()),
        );
      } else {
        // Jika hanya ada sesi (pasti admin) -> ke Beranda Admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeAdminScreen()),
        );
      }
    } else {
      // Jika tidak ada sesi sama sekali -> ke Halaman Selamat Datang
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7986CB),
        ),
      ),
    );
  }
}