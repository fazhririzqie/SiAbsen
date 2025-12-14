import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:si_absen/beranda_admin.dart'; // Ubah import ini
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:si_absen/beranda_guru.dart';

class ResultScreen extends StatefulWidget {
  final String? imagePath;
  final int hadirCount;
  final int classNumber;

  const ResultScreen(
      {super.key,
        this.imagePath,
        this.hadirCount = 0,
        required this.classNumber});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  Map<String, String?> _studentAbsenceList = {};

  static const Map<int, int> _totalStudentsPerClass = {
    5: 35,
    6: 36,
  };

  // --- WARNA ---
  static const Color _menuIconBgColor = Color(0xFFE8EAF6);
  static const Color _menuIconColor = Color(0xFF3F51B5);
  static const Color _activeTabColor = Color(0xFFD32F2F);
  static const Color _buttonColor = Color(0xFF7986CB);

  @override
  void initState() {
    super.initState();
    _fetchStudentsByClass();
  }

  Future<void> _fetchStudentsByClass() async {
    try {
      final List<Map<String, dynamic>> data = await Supabase.instance.client
          .from('murid')
          .select('nama_murid')
          .eq('kelas', widget.classNumber)
          .order('nama_murid', ascending: true);

      final Map<String, String?> studentMap = {
        for (var student in data) student['nama_murid'] as String: null
      };

      setState(() {
        _studentAbsenceList = studentMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data murid: $e')),
        );
      }
    }
  }

  int get _calculatedAbsentCount {
    final totalStudents = _totalStudentsPerClass[widget.classNumber] ?? 0;
    final absentCount = totalStudents - widget.hadirCount;
    return absentCount > 0 ? absentCount : 0;
  }

  Future<void> _showAbsenceReasonDialog(String studentName) async {
    String? selectedReason = _studentAbsenceList[studentName] ?? 'Tanpa Keterangan';

    final reason = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Alasan Tidak Hadir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: ['Sakit', 'Izin', 'Tanpa Keterangan'].map((reason) {
                  return RadioListTile<String>(
                    title: Text(reason),
                    value: reason,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                    activeColor: _menuIconColor,
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(selectedReason);
              },
            ),
          ],
        );
      },
    );

    if (reason != null) {
      setState(() {
        _studentAbsenceList[studentName] = reason;
      });
    }
  }


  Future<void> _saveAttendance() async {
    setState(() {
      _isSaving = true;
    });

    try {
      String? imageUrl;
      if (widget.imagePath != null) {
        final imageFile = File(widget.imagePath!);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bucket = 'absensi_images';

        await Supabase.instance.client.storage.from(bucket).upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

        imageUrl = Supabase.instance.client.storage.from(bucket).getPublicUrl(fileName);
      }

      final List<String> absentStudentDetails = _studentAbsenceList.entries
          .where((entry) => entry.value != null)
          .map((entry) => '${entry.key} (${entry.value})')
          .toList();

      final attendanceData = {
        'image_url': imageUrl,
        'hari': DateFormat('EEEE', 'id_ID').format(DateTime.now()),
        'tanggal': DateTime.now().toIso8601String(),
        'kelas': widget.classNumber,
        'jumlah_hadir': widget.hadirCount,
        'jumlah_tidak_hadir': _calculatedAbsentCount,
        'nama_murid_tidak_hadir': absentStudentDetails,
      };

      // 4. Masukkan data ke tabel 'riwayat_absen'
      await Supabase.instance.client.from('riwayat_absen').insert(attendanceData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasil absensi berhasil disimpan.'),
          backgroundColor: Colors.green,
        ),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }


    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildContentBody(),
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
                'Hasil Absen',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd, MMMM yyyy', 'id_ID')
                    .format(DateTime.now()),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          // Tombol Menu
          GestureDetector(
            onTap: () {

              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _menuIconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close,
                color: _menuIconColor,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hasil',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildResultImage(),
          Container(
            height: 3,
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                color: _selectedTabIndex == 0
                    ? _activeTabColor
                    : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTabs(),
          const SizedBox(height: 16),
          _buildSummaryNumbers(),
          const Divider(height: 32),
          _buildAbsenteeSelector(),
          const SizedBox(height: 32),
          _buildSaveButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildResultImage() {
    if (widget.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Image.file(
          File(widget.imagePath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Image.network(
        'https://images.unsplash.com/photo-1577896851231-70ef18881754?w=800',
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _buildTabItem('Hadir', 0),
        _buildTabItem('Tidak Hadir', 1),
      ],
    );
  }

  Widget _buildTabItem(String title, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryNumbers() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${widget.hadirCount}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _selectedTabIndex == 0 ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            '$_calculatedAbsentCount',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _selectedTabIndex == 1 ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbsenteeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih murid yang tidak hadir',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                'Kelas ${widget.classNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              initiallyExpanded: true,
              children: _isLoading
                  ? [
                const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ))
              ]
                  : _buildCheckboxList(),
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _buildCheckboxList() {
    if (_studentAbsenceList.isEmpty) {
      return [const ListTile(title: Text('Tidak ada data murid di kelas ini.'))];
    }

    List<String> studentNames = _studentAbsenceList.keys.toList();

    return studentNames.map((name) {
      final bool isChecked = _studentAbsenceList[name] != null;
      final String subtitle = isChecked ? 'Alasan: ${_studentAbsenceList[name]}' : '';

      return CheckboxListTile(
        title: Text(name, style: const TextStyle(fontSize: 16)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: Colors.grey[600])) : null,
        value: isChecked,
        onChanged: (bool? newValue) {
          if (newValue == true) {
            _showAbsenceReasonDialog(name);
          } else {
            setState(() {
              _studentAbsenceList[name] = null;
            });
          }
        },
        controlAffinity: ListTileControlAffinity.trailing,
        activeColor: _menuIconColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      );
    }).toList();
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isSaving ? null : _saveAttendance,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          foregroundColor: _buttonColor,
          side: const BorderSide(color: _buttonColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: _buttonColor),
        )
            : const Text(
          'Simpan Hasil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
