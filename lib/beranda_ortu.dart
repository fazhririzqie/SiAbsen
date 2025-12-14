import 'package:flutter/material.dart';
import 'package:si_absen/login_guru.dart'; // Diperlukan untuk Logout

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Report Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ReportScreen(),
    );
  }
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late PageController _reportController;
  int _reportPage = 0;

  // --- WARNA ---
  static const Color _menuIconBgColor = Color(0xFFE8EAF6);
  static const Color _menuIconColor = Color(0xFF3F51B5);
  static const Color _brandColor = Color(0xFFD32F2F);
  static const Color _cardColor = Color(0xFFF5F5F5);
  static const Color _buttonColor = Color(0xFF7986CB);
  static const Color _activeDotColor = Colors.orange;
  static const Color _inactiveDotColor = Color(0xFFE0E0E0);

  // Data Pie Chart sudah tidak diperlukan
  // final Map<String, double> _chartData = ...
  // final List<Color> _chartColorList = ...

  @override
  void initState() {
    super.initState();
    _reportController = PageController();
  }

  @override
  void dispose() {
    _reportController.dispose();
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
              _buildHeader(), // Header sudah diubah
              const SizedBox(height: 16),
              // _buildMonthlyChartCard(), // <-- Grafik Pie Dihapus

              // Menampilkan judul "Riwayat Laporan"
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Riwayat Laporan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Menampilkan kartu laporan 2x
              _buildReportHistorySection(),
              const SizedBox(height: 16), // Jarak antar kartu
              _buildReportHistorySection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // --- HEADER DIUBAH MENYESUAIKAN GAMBAR ---
  // -----------------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom kiri: Logo, Nama, Tanggal
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.school, // Ikon default pengganti logo
                color: _brandColor,
                size: 40,
              ),
              const SizedBox(height: 8),
              const Text(
                'Orang Tua Murid', // <-- Judul diubah
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
          // Tombol Menu
          GestureDetector(
            onTap: _showMenuBottomSheet, // <-- Panggil bottom sheet menu
            child: Container(
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
          ),
        ],
      ),
    );
  }
  // --- AKHIR PERUBAHAN HEADER ---

  // Grafik Pie chart dihapus, tidak perlu `_buildMonthlyChartCard`
  // Widget _buildMonthlyChartCard() { ... }

  // Fungsi ini sudah tidak diperlukan
  // Widget _buildLegendItem({required Color color, required String text}) { ... }

  // -----------------------------------------------------------------
  // --- FUNGSI BARU UNTUK BOTTOM SHEET MENU ---
  // -----------------------------------------------------------------
  void _showMenuBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black54,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        final double screenWidth = MediaQuery.of(context).size.width;
        return SafeArea(
          bottom: true,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: screenWidth,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
                ),
                child: _buildMenuSheet(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuSheet() {
    // Menu untuk Orang Tua hanya berisi Logout
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLogoutButton(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        print('Logout Tapped');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
        foregroundColor: _menuIconColor,
        side: BorderSide(color: _menuIconColor.withOpacity(0.5), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: const Text(
        'Logout',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
  // --- AKHIR FUNGSI BOTTOM SHEET ---


  Widget _buildReportHistorySection() {
    // Data ini sekarang digunakan untuk *setiap* kartu
    final List<Widget> historyPages = [
      _buildReportHistoryPage(
        date: "Sabtu, 25 Oktober 2025",
        className: "Kelas 5",
        present: 35,
        absent: 3,
        absentStudents: ["Savannah Nguyen", "Devon Lane", "John Doe"],
      ),
      _buildReportHistoryPage(
        date: "Jumat, 24 Oktober 2025",
        className: "Kelas 5",
        present: 38,
        absent: 0,
        absentStudents: [],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        color: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              SizedBox(
                height: 320,
                child: PageView.builder(
                  // Gunakan controller yang sama atau controller baru jika perlu state terpisah
                  controller: _reportController,
                  itemCount: historyPages.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _reportPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return historyPages[index];
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildPageIndicator(
                currentPage: _reportPage,
                numPages: historyPages.length,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportHistoryPage({
    required String date,
    required String className,
    required int present,
    required int absent,
    required List<String> absentStudents,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Laporan
          Text(
            'Laporan Harian ($date)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            className,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(
                  title: 'Hadir',
                  icon: Icons.check,
                  color: Colors.green,
                  count: present),
              _buildStatColumn(
                  title: 'Tidak Hadir',
                  icon: Icons.close,
                  color: _brandColor,
                  count: absent),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Murid yang tidak hadir',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(thickness: 1, height: 24),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: absentStudents.length,
              itemBuilder: (context, index) {
                if (absentStudents.isEmpty) {
                  return const Text("-", style: TextStyle(fontSize: 16));
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    absentStudents[index],
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
  }) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 8),
        Icon(icon, color: color, size: 50),
        const SizedBox(height: 8),
        Text('$count Orang',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
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