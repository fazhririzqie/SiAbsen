import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late PageController _reportController;
  late PageController _historyController;
  int _reportPage = 0;
  int _historyPage = 0;

  
  static const Color _menuIconBgColor = Color(0xFFE8EAF6); 
  static const Color _menuIconColor = Color(0xFF3F51B5); 
  static const Color _brandColor = Color(0xFFD32F2F); 
  static const Color _cardColor = Color(0xFFF5F5F5); 
  static const Color _activeDotColor = Colors.orange; 
  static const Color _inactiveDotColor = Color(0xFFE0E0E0); 

  @override
  void initState() {
    super.initState();
    _reportController = PageController();
    _historyController = PageController();
  }

  @override
  void dispose() {
    _reportController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildMenuGrid(),
              _buildDailyReportCard(),
              _buildHistoryCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Image.asset(
                  'images/logosd.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  semanticLabel: 'Logo Sekolah',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nama Guru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '25, Oktober 2025', 
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _menuIconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu,
              color: _menuIconColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
  
  
  Widget _buildMenuGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildMenuCard(
              icon: Icons.face_retouching_natural,
              label: 'Absen Murid',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildMenuCard(
              icon: Icons.bar_chart, 
              label: 'Laporan',
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildMenuCard({required IconData icon, required String label}) {
    return Card(
      elevation: 0,
      color: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            Icon(icon, size: 50, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildDailyReportCard() {

    final List<Widget> reportPages = [
      _buildReportPage(className: 'Kelas 6', present: 35, absent: 3),
      _buildReportPage(className: 'Kelas 5', present: 30, absent: 1),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 0,
        color: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Laporan Harian',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150, 
                child: PageView.builder(
                  controller: _reportController,
                  itemCount: reportPages.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _reportPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return reportPages[index];
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Indikator halaman
              Center(
                child: _buildPageIndicator(
                  currentPage: _reportPage,
                  numPages: reportPages.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildReportPage({
    required String className,
    required int present,
    required int absent,
  }) {
    return Column(
      children: [
        Text(
          className,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            
            Column(
              children: [
                const Text('Hadir', style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 8),
                const Icon(Icons.check, color: Colors.green, size: 50),
                const SizedBox(height: 8),
                Text('$present Orang', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
           
            Column(
              children: [
                const Text('Tidak Hadir', style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 8),
                const Icon(Icons.close, color: Colors.red, size: 50),
                const SizedBox(height: 8),
                Text('$absent Orang', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  
  Widget _buildHistoryCard() {
    
    final List<String> historyImages = [
      
      'images/fotosd1.jpeg',
      
      'images/fotosd2.jpeg',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        color: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Riwayat Absensi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _historyController,
                  itemCount: historyImages.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _historyPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          historyImages[index], // e.g. "images/fotosd1.jpeg"
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
             
              Center(
                child: _buildPageIndicator(
                  currentPage: _historyPage,
                  numPages: historyImages.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildPageIndicator({required int currentPage, required int numPages}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(numPages, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: currentPage == index ? _activeDotColor : _inactiveDotColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}