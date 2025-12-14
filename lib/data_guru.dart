import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherTableScreen extends StatefulWidget {
  const TeacherTableScreen({super.key});

  @override
  State<TeacherTableScreen> createState() => _TeacherTableScreenState();
}

class _TeacherTableScreenState extends State<TeacherTableScreen> {
  late Future<List<Map<String, dynamic>>> _teachersFuture;

  // Warna untuk garis header
  static const Color _headerBorderColor = Color(0xFFE91E63); // Pinkish-Red

  @override
  void initState() {
    super.initState();
    _teachersFuture = _fetchTeachers();
  }

  /// Mengambil data dari tabel 'guru' di Supabase
  Future<List<Map<String, dynamic>>> _fetchTeachers() async {
    try {
      final data = await Supabase.instance.client
          .from('guru')
          .select('nama_guru, kelas')
          .order('nama_guru', ascending: true);
      return data;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data guru: $e')),
        );
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Data Guru',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _teachersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
            }
            final teachers = snapshot.data;
            if (teachers == null || teachers.isEmpty) {
              return const Center(child: Text('Tidak ada data guru.'));
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildHeaderRow(),
                    ...teachers.map((teacher) {
                      return _buildDataRow(
                        teacher['nama_guru'] ?? 'Tanpa Nama',
                        teacher['kelas']?.toString() ?? '-',
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    // ... (Widget ini tidak perlu diubah)
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _headerBorderColor, width: 1.5),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Nama Guru',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Kelas yang diajar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String name, String className) {
    // ... (Widget ini tidak perlu diubah)
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              className,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
