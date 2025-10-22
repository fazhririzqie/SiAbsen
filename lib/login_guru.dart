// lib/login_guru.dart
import 'package:flutter/material.dart';
import 'package:si_absen/login_admin.dart';
import 'package:si_absen/login_ortu.dart';
import 'package:si_absen/beranda_guru.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const Color _brandColor = Color(0xFFEC407A);
  static const Color _buttonColor = Color(0xFF7986CB);
  static const Color _fieldBorderColor = Color(0xFFE0E0E0);
  static const Color _focusedBorderColor = Color(0xFF7986CB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeText(),
                const SizedBox(height: 24.0),
                _buildLogo(),
                const SizedBox(height: 40.0),
                _buildTextField(
                  controller: _usernameController,
                  labelText: 'Username',
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 32.0),
                _buildLoginButton(),
                const SizedBox(height: 24.0),
                _buildBottomLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Poppins',
            height: 1.3,
          ),
          children: <TextSpan>[
            TextSpan(text: 'Halo,\n'),
            TextSpan(text: 'Selamat Datang\ndi '),
            TextSpan(
              text: 'SiAbsen.',
              style: TextStyle(
                color: _brandColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New logo widget
  Widget _buildLogo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Image.asset(
          'images/logosd.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: _fieldBorderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: _focusedBorderColor, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
          String username = _usernameController.text;
          String password = _passwordController.text;
          print('Login attempt with: $username, $password');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Login',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBottomLinks() {
    return Center(
      child: Column(
        children: [
          _buildClickableLink(
            prefixText: 'Apakah anda ADMIN? ',
            linkText: 'MASUK',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPageAdmin()),
              );
              print('Admin login tapped');
            },
          ),
          const SizedBox(height: 8.0),
          _buildClickableLink(
            prefixText: 'Apakah anda Orang Tua Murid? ',
            linkText: 'MASUK',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPageOrtu()),
              );
              print('Parent login tapped');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClickableLink({
    required String prefixText,
    required String linkText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
          children: [
            TextSpan(text: prefixText),
            TextSpan(
              text: linkText,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
