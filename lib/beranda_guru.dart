import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_absen/laporan.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:si_absen/data_murid.dart';
import 'package:si_absen/selamat_datang.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'hasil_absen.dart';


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
  String _namaGuru = "Guru";

  Map<int, Map<String, dynamic>> _latestReports = {};
  bool _isLoadingReports = true;


  static const Color _menuIconBgColor = Color(0xFFE8EAF6);
  static const Color _menuIconColor = Color(0xFF3F51B5);
  static const Color _brandColor = Color(0xFFD32F2F);
  static const Color _cardColor = Color(0xFFF5F5F5);
  static const Color _activeDotColor = Colors.orange;
  static const Color _inactiveDotColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _reportController = PageController();
    _historyController = PageController();
    _loadGuruData();
    _fetchLatestReports();
  }

  @override
  void dispose() {
    _reportController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestReports() async {
    try {
      final List<int> classes = [5, 6];
      final Map<int, Map<String, dynamic>> reports = {};

      for (int classNum in classes) {
        final data = await Supabase.instance.client
            .from('riwayat_absen')
            .select()
            .eq('kelas', classNum)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (data != null) {
          reports[classNum] = data;
        }
      }

      if (mounted) {
        setState(() {
          _latestReports = reports;
          _isLoadingReports = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReports = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat laporan terakhir: $e')),
        );
      }
    }
  }


  Future<void> _loadGuruData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaGuru = prefs.getString('nama_guru') ?? 'Guru';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
    );
  }




  Future<void> _capturePhoto(int classNumber) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final options = FaceDetectorOptions();
      final faceDetector = FaceDetector(options: options);
      final faces = await faceDetector.processImage(inputImage);
      final faceCount = faces.length;
      faceDetector.close();

      if (!mounted) return;


      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imagePath: pickedFile.path,
            hadirCount: faceCount,

            classNumber: classNumber,
          ),
        ),
      );

      _fetchLatestReports();
    }
  }




  void _showClassSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext bc) {
        return _buildClassSelectorSheet();
      },
    );
  }

  Widget _buildClassSelectorSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Kelas yang akan diabsen',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mengirimkan nomor kelas (5)
              _buildClassCard(className: 'Kelas 5', icon: Icons.book_outlined, classNumber: 5),
              // Mengirimkan nomor kelas (6)
              _buildClassCard(className: 'Kelas 6', icon: Icons.book_outlined, classNumber: 6),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildClassCard({required String className, required IconData icon, required int classNumber}) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        await _capturePhoto(classNumber);
      },
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: _menuIconColor),
            const SizedBox(height: 12),
            Text(
              className,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDataMuridCard(),
        const SizedBox(height: 24),
        _buildLogoutButton(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDataMuridCard() {
    return InkWell(
      onTap: () {
        print('Data Murid Tapped');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentListScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_outlined, size: 40, color: _menuIconColor),
            const SizedBox(height: 12),
            const Text(
              'Data Murid',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton(
      onPressed: _logout, // Panggil fungsi _logout
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
              Text(
                _namaGuru, // Gunakan state _namaGuru
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd, MMMM yyyy', 'id_ID').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _showMenuBottomSheet,
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


  Widget _buildMenuGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showClassSelector,
              child: _buildMenuCard(
                icon: Icons.face_retouching_natural,
                label: 'Absen Murid',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportScreen()),
                );
              },
              child: _buildMenuCard(
                icon: Icons.bar_chart,
                label: 'Laporan',
              ),
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
    final List<int> classOrder = [6, 5];

    final List<Widget> reportPages = classOrder.map((classNum) {
      final report = _latestReports[classNum];
      return _buildReportPage(
        className: 'Kelas $classNum',
        present: report?['jumlah_hadir'] ?? 0,
        absent: report?['jumlah_tidak_hadir'] ?? 0,
      );
    }).toList();

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
                child: _isLoadingReports
                    ? const Center(child: CircularProgressIndicator())
                    : reportPages.isEmpty
                    ? const Center(child: Text('Tidak ada laporan.'))
                    : PageView.builder(
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
                const Text('Hadir',
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 8),
                const Icon(Icons.check, color: Colors.green, size: 50),
                const SizedBox(height: 8),
                Text('$present Orang',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              children: [
                const Text('Tidak Hadir',
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 8),
                const Icon(Icons.close, color: Colors.red, size: 50),
                const SizedBox(height: 8),
                Text('$absent Orang',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryCard() {
    final List<int> classOrder = [6, 5];

    final List historyImages = classOrder.map((classNum) {
      final report = _latestReports[classNum];
      return (report != null && report['image_url'] != null && report['image_url'].isNotEmpty)
          ? report['image_url']
          : 'https://via.placeholder.com/400x200.png?text=No+Image';
    }).toList();

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
                child: _isLoadingReports
                    ? const Center(child: CircularProgressIndicator())
                    : historyImages.isEmpty
                    ? const Center(child: Text('Tidak ada riwayat.'))
                    : PageView.builder(
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
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          historyImages[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stack) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
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
    if (numPages <= 0) return const SizedBox.shrink();

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
