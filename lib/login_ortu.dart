import 'package:flutter/material.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Ortu Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const LoginPageOrtu(),
    );
  }
}

class LoginPageOrtu extends StatefulWidget {
  const LoginPageOrtu({super.key});

  @override
  State<LoginPageOrtu> createState() => _LoginPageOrtuState();
}

class _LoginPageOrtuState extends State<LoginPageOrtu> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const Color _brandColor = Color(0xFFEC407A);
  static const Color _buttonColor = Color(0xFF7986CB);
  static const Color _fieldBorderColor = Color(0xFFE0E0E0);
  static const Color _focusedBorderColor = Color(0xFF7986CB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
              splashRadius: 24,
            ),
          ),
        ),
      ),

      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildWelcomeText(),
                const SizedBox(height: 70.0),
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
            TextSpan(text: 'Halaman Login\n'),
            TextSpan(text: 'Orang Tua', style: TextStyle(color: _brandColor)),
          ],
        ),
      ),
    );
  }

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
}