import 'dart:async'; // Diperlukan untuk Timer
import 'package:flutter/material.dart';
import 'package:si_absen/login_guru.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Onboarding Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  late PageController _pageController;

  Timer? _timer;

  int _currentPage = 0;


  static const Color _brandColor = Color(0xFFEC407A); // Pink/Merah
  static const Color _buttonColor = Color(0xFF7986CB); // Biru/Ungu

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);


    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {

      int nextPage = _currentPage == 0 ? 1 : 0;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {

    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Column(
                children: [
                  const SizedBox(height: 48),

                  const Text(
                    'SiAbsen.',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: _brandColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '"Satu Sentuhan untuk Kehadiran yang Tepat"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),


              Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PageView(
                      controller: _pageController,

                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        _buildLogoImage(asset: 'images/logosd.png'),
                        _buildLogoImage(asset: 'images/indonesia.png'),
                      ],

                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPageIndicator(isActive: _currentPage == 0),
                      const SizedBox(width: 8),
                      _buildPageIndicator(isActive: _currentPage == 1),
                    ],
                  ),
                ],
              ),


              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
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
                    'Get Started',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLogo({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Icon(
        icon,
        size: 150,
        color: color,
      ),
    );
  }


  Widget _buildPageIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? _brandColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// dart
Widget _buildLogoImage({required String asset}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        width: 200,
        height: 200,
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    ),
  );
}