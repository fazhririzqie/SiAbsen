import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  Map<String, List<String>> _classes = {};
  Map<String, bool> _isExpanded = {};
  bool _isLoading = true;

  static const Color _cardColor = Colors.white;
  static final Color _borderColor = Colors.grey.shade200;
  static const double _borderRadius = 12.0;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  /// Mengambil data murid dan mengelompokkannya berdasarkan kelas
  Future<void> _fetchStudents() async {
    try {
      final List<Map<String, dynamic>> data = await Supabase.instance.client
          .from('murid')
          .select('nama_murid, kelas')
          .order('kelas', ascending: true)
          .order('nama_murid', ascending: true);

      final Map<String, List<String>> groupedData = {};
      final Map<String, bool> expandedState = {};

      for (var student in data) {
        final className = 'Kelas ${student['kelas']}';
        final studentName = student['nama_murid'] as String;
        if (!groupedData.containsKey(className)) {
          groupedData[className] = [];
          expandedState[className] = true;
        }
        groupedData[className]!.add(studentName);
      }

      setState(() {
        _classes = groupedData;
        _isExpanded = expandedState;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Data Murid',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _classes.isEmpty
            ? const Center(child: Text('Tidak ada data murid.'))
            : ListView(
          padding: const EdgeInsets.all(16.0),
          children: _classes.keys.map((className) {
            return _buildClassDropdown(className, _classes[className]!);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildClassDropdown(String className, List<String> students) {
    // ... (Widget ini tidak perlu diubah)
    bool isExpanded = _isExpanded[className] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Material(
            color: _cardColor,
            borderRadius: BorderRadius.circular(_borderRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(_borderRadius),
              onTap: () {
                setState(() {
                  _isExpanded[className] = !isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_borderRadius),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      className,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: _buildStudentList(students),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<String> students) {
    // ... (Widget ini tidak perlu diubah)
    return Container(
      margin: const EdgeInsets.only(top: 4.0),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: _borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: students.map((student) {
          return ListTile(
            title: Text(
              student,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          );
        }).toList(),
      ),
    );
  }
}
