import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_absen/hasil_absen.dart';
import 'package:si_absen/laporan.dart';
import 'package:si_absen/data_guru.dart';
import 'package:si_absen/data_murid.dart';
import 'package:si_absen/selamat_datang.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';



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
      home: const HomeAdminScreen(),
    );
  }
}

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeAdminScreen> {
  late PageController _reportController;
  late PageController _historyController;
  int _reportPage = 0;
  int _historyPage = 0;
  String? _selectedKelas;

  File? _selectedFile;

  final _namaGuruController = TextEditingController();
  final _emailGuruController = TextEditingController();
  final _passwordGuruController = TextEditingController();
  final _confirmPasswordGuruController = TextEditingController();

  // State untuk menyimpan laporan terakhir
  Map<int, Map<String, dynamic>> _latestReports = {};
  bool _isLoadingReports = true;

  static const Color _menuIconBgColor = Color(0xFFE8EAF6);
  static const Color _menuIconColor = Color(0xFF3F51B5);
  static const Color _brandColor = Color(0xFFD32F2F);
  static const Color _cardColor = Color(0xFFF5F5F5);
  static const Color _activeDotColor = Colors.orange;
  static const Color _inactiveDotColor = Color(0xFFE0E0E0);
  static const Color _fieldBorderColor = Color(0xFFE0E0E0);
  static const Color _focusedBorderColor = Color(0xFF7986CB);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _reportController = PageController();
    _historyController = PageController();
    _fetchLatestReports();
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


  /// Menambahkan data guru
  Future<void> _addGuru() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final classController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Guru Baru'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Guru'),
                    validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  TextFormField(
                    controller: classController,
                    decoration: const InputDecoration(labelText: 'Kelas yang Diajar'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty ? 'Kelas tidak boleh kosong' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                    value!.isEmpty ? 'Email tidak boleh kosong' : null,
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) =>
                    value!.isEmpty ? 'Password tidak boleh kosong' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Tambah'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    // 1. Create user in Supabase Auth
                    final authResponse =
                    await Supabase.instance.client.auth.signUp(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );

                    if (authResponse.user != null) {
                      await Supabase.instance.client.from('guru').insert({
                        'user_id': authResponse.user!.id,
                        'nama_guru': nameController.text.trim(),
                        'kelas': int.parse(classController.text.trim()),
                      });

                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Guru berhasil ditambahkan.'),
                              backgroundColor: Colors.green),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Gagal menambahkan guru: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _uploadDataMuridFromCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.single.path == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada file yang dipilih.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      var file = File(result.files.single.path!);
      var contents = await file.readAsString();

      // Parse CSV
      List<List<dynamic>> rows = const CsvToListConverter().convert(contents);

      if (rows.isEmpty || rows.length < 2) {
        throw 'File CSV kosong atau tidak memiliki data.';
      }

      final List<Map<String, dynamic>> dataMurid = [];

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];

        if (row.every((cell) => cell == null || cell.toString().trim().isEmpty)) {
          continue;
        }

        if (row.isNotEmpty && row[0] != null && row[0].toString().trim().isNotEmpty) {
          final dynamic nisnValue = row[0];
          final String? namaMurid = (row.length > 1) ? row[1]?.toString().trim() : null;
          final String? jenisKelamin = (row.length > 2) ? row[2]?.toString().trim() : null;
          final dynamic kelasValue = (row.length > 3) ? row[3] : null;

          if (namaMurid == null || namaMurid.isEmpty) {
            continue;
          }

          int? nisn;
          if (nisnValue is num) {
            nisn = nisnValue.toInt();
          } else if (nisnValue is String) {
            nisn = int.tryParse(nisnValue.trim());
          }

          int? kelas;
          if (kelasValue is num) {
            kelas = kelasValue.toInt();
          } else if (kelasValue is String) {
            kelas = int.tryParse(kelasValue.toString().trim());
          }

          if (nisn != null) {
            dataMurid.add({
              'nisn': nisn,
              'nama_murid': namaMurid,
              'jenis_kelamin': jenisKelamin,
              'kelas': kelas,
            });
          }
        }
      }

      if (dataMurid.isEmpty) {
        throw 'Tidak ada data valid untuk diunggah. Pastikan file tidak kosong dan formatnya benar.';
      }

      await Supabase.instance.client.from('murid').insert(dataMurid);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dataMurid.length} data murid berhasil diunggah.')),
      );

    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }



  @override
  void dispose() {
    _reportController.dispose();
    _historyController.dispose();
    _namaGuruController.dispose();
    _emailGuruController.dispose();
    _passwordGuruController.dispose();
    _confirmPasswordGuruController.dispose();
    super.dispose();
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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imagePath: pickedFile.path,
            hadirCount: faceCount,
            classNumber: classNumber,
          ),
        ),
      );
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
              _buildClassCard(className: 'Kelas 5', icon: Icons.book_outlined, classNumber: 5),
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuItemCard(
              label: 'Data Guru',
              icon: Icons.person_search_outlined,
            ),
            _buildMenuItemCard(
              label: 'Data Murid',
              icon: Icons.groups_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildLogoutButton(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMenuItemCard({required String label, required IconData icon}) {
    return InkWell(
      onTap: () {
        print('$label Tapped');
        Navigator.pop(context);
        if (label == 'Data Guru') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TeacherTableScreen()),
          );
        } else if (label == 'Data Murid') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudentListScreen()),
          );
        }
      },
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 24.0),
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
              label,
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

  Widget _buildLogoutButton() {
    return OutlinedButton(
      onPressed: () async {
        try {
          await Supabase.instance.client.auth.signOut();

          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                (route) => false,
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal logout: $e')),
          );
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
        foregroundColor: const Color(0xFF3F51B5),
        side: BorderSide(color: const Color(0xFF3F51B5).withOpacity(0.5), width: 1.5),
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


  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: _showAddBottomSheet,
      backgroundColor: _menuIconColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }


  void _showAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext bc) {
        return _buildAddSheet();
      },
    );
  }


  Widget _buildAddSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAddItemCard(
                label: 'Tambah Guru',
                icon: Icons.person_add_alt_1_outlined,
              ),
              _buildAddItemCard(
                label: 'Tambah Murid',
                icon: Icons.group_add_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }


  Widget _buildAddItemCard({required String label, required IconData icon}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (label == 'Tambah Murid') {
          _showUploadMuridSheet();
        } else if (label == 'Tambah Guru') {
          _addGuru();
        }
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
              label,
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



  void _showUploadMuridSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Unggah Data Murid',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Pastikan file CSV Anda memiliki kolom: NISN, Nama, Jenis Kelamin, Kelas.'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Pilih File CSV'),
                onPressed: () {
                  Navigator.pop(context);
                  _uploadDataMuridFromCSV();
                },
              ),
            ],
          ),
        );
      },
    );
  }





  Future<void> _pickFile(StateSetter setState) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    } else {
      print("Pemilihan file dibatalkan.");
    }
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
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                'ADMIN',
                style: TextStyle(
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
    // Urutan kelas untuk ditampilkan di PageView
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
    // Urutan kelas untuk ditampilkan di PageView
    final List<int> classOrder = [6, 5];

    final List historyImages = classOrder.map((classNum) {
      final report = _latestReports[classNum];
      // Jika ada laporan dan URL gambar tidak kosong, gunakan URL tersebut.
      // Jika tidak, gunakan placeholder.
      return (report != null && report['image_url'] != null && report['image_url'].isNotEmpty)
          ? report['image_url']
          : 'https://via.placeholder.com/400x200.png?text=No+Image'; // Placeholder URL
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
    // Jangan tampilkan indikator jika tidak ada halaman
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
