import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataMuridGuruScreen extends StatefulWidget {
  final String kelasGuru;

  const DataMuridGuruScreen({super.key, required this.kelasGuru});

  @override
  State<DataMuridGuruScreen> createState() => _DataMuridGuruScreenState();
}

class _DataMuridGuruScreenState extends State<DataMuridGuruScreen> {
  late Future<List<String>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _fetchStudentsByClass();
  }

  /// Mengambil data murid berdasarkan kelas guru.
  Future<List<String>> _fetchStudentsByClass() async {
    try {
      // Mengambil data dari tabel 'murid' dengan filter 'kelas'
      final List<Map<String, dynamic>> data = await Supabase.instance.client
          .from('murid')
          .select('nama_murid')
          .eq('kelas', widget.kelasGuru) // Filter berdasarkan kelas guru
          .order('nama_murid', ascending: true);

      // Mengubah hasil query menjadi daftar nama murid
      final List<String> studentNames =
          data.map((student) => student['nama_murid'] as String).toList();

      return studentNames;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data murid: $e')),
        );
      }
      // Mengembalikan list kosong jika terjadi error
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Data Murid Kelas ${widget.kelasGuru}',
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: FutureBuilder<List<String>>(
          future: _studentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
            }
            final students = snapshot.data;
            if (students == null || students.isEmpty) {
              return const Center(
                  child: Text('Tidak ada data murid di kelas ini.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: students.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    title: Text(students[index]),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}