import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pie_chart/pie_chart.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;
  late Future<Map<String, double>> _weeklySummaryFuture;

  static const Color _hadirColor = Color(0xFF2E7D32);
  static const Color _tidakHadirColor = Color(0xFFC62828);
  static final Color _cardBackgroundColor = Colors.grey.shade50;
  static final Color _borderColor = Colors.grey.shade200;

  final List<Color> _colorList = <Color>[
    _hadirColor,
    _tidakHadirColor,
  ];

  @override
  void initState() {
    super.initState();
    _reportsFuture = _fetchReports();
    _weeklySummaryFuture = _fetchWeeklySummary();
  }

  Future<List<Map<String, dynamic>>> _fetchReports() async {
    try {
      final data = await Supabase.instance.client
          .from('riwayat_absen')
          .select()
          .order('created_at', ascending: false);
      return data;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat laporan harian: ${e.toString()}')),
        );
      }
      return [];
    }
  }


  Future<Map<String, double>> _fetchWeeklySummary() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final data = await Supabase.instance.client
          .from('riwayat_absen')
          .select('jumlah_hadir, jumlah_tidak_hadir')
          .gte('tanggal', sevenDaysAgo.toIso8601String())
          .lte('tanggal', now.toIso8601String());

      double totalHadir = 0;
      double totalTidakHadir = 0;

      for (var row in data) {
        totalHadir += (row['jumlah_hadir'] as num?)?.toDouble() ?? 0.0;
        totalTidakHadir += (row['jumlah_tidak_hadir'] as num?)?.toDouble() ?? 0.0;
      }

      return {
        'Hadir': totalHadir,
        'Tidak Hadir': totalTidakHadir,
      };
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat ringkasan mingguan: ${e.toString()}')),
        );
      }
      return {'Hadir': 0, 'Tidak Hadir': 0};
    }
  }

  Future<void> _exportToCsv() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final reports = await Supabase.instance.client
          .from('riwayat_absen')
          .select()
          .gte('tanggal', sevenDaysAgo.toIso8601String())
          .lte('tanggal', now.toIso8601String())
          .order('tanggal', ascending: false);

      if (reports.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada data untuk diekspor dalam 7 hari terakhir.')),
          );
        }
        return;
      }

      List<List<dynamic>> rows = [];
      rows.add([
        'Tanggal',
        'Hari',
        'Kelas',
        'Jumlah Hadir',
        'Jumlah Tidak Hadir',
        'Murid Tidak Hadir'
      ]);

      for (var report in reports) {
        final List<String> muridTidakHadir =
            (report['nama_murid_tidak_hadir'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
                [];
        rows.add([
          report['tanggal'],
          report['hari'],
          report['kelas'],
          report['jumlah_hadir'],
          report['jumlah_tidak_hadir'],
          muridTidakHadir.join(', ')
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final String? directory = await FilePicker.platform.getDirectoryPath();

      if (directory != null) {
        final String fileName = 'laporan_absen_mingguan_${DateFormat('yyyy-MM-dd').format(now)}.csv';
        final String path = '$directory/$fileName';
        final File file = File(path);

        await file.writeAsString(csv);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Laporan berhasil diekspor ke: $path')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ekspor dibatalkan.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor data: ${e.toString()}')),
        );
      }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Laporan Absensi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWeeklySummaryCard(),
              const SizedBox(height: 24),
              const Text(
                'Riwayat Harian',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDailyHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Mingguan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, double>>(
              future: _weeklySummaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Data ringkasan tidak tersedia.'));
                }
                final summaryData = snapshot.data!;
                final bool isEmpty = summaryData.values.every((v) => v == 0);

                return isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Text('Belum ada data untuk 7 hari terakhir.'),
                  ),
                )
                    : PieChart(
                  dataMap: summaryData,
                  animationDuration: const Duration(milliseconds: 800),
                  chartLegendSpacing: 32,
                  chartRadius: MediaQuery.of(context).size.width / 3.2,
                  colorList: _colorList,
                  initialAngleInDegree: 0,
                  chartType: ChartType.ring,
                  ringStrokeWidth: 32,
                  legendOptions: const LegendOptions(
                    showLegendsInRow: true,
                    legendPosition: LegendPosition.bottom,
                    showLegends: true,
                    legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValueBackground: true,
                    showChartValues: true,
                    showChartValuesInPercentage: false,
                    showChartValuesOutside: false,
                    decimalPlaces: 0,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _exportToCsv,
                icon: const Icon(Icons.download_for_offline_outlined),
                label: const Text('Export to Excel'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF1D6F42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyHistoryList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _reportsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }
        final reports = snapshot.data;
        if (reports == null || reports.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('Tidak ada riwayat laporan.'),
          ));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            return _buildReportCard(reports[index]);
          },
        );
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final int reportId = report['id'];
    final String imageUrl = report['image_url'] ?? '';
    final String hari = report['hari'] ?? 'Tidak diketahui';
    final DateTime tanggal = DateTime.parse(report['tanggal']);
    final String tanggalFormatted = DateFormat('d MMMM yyyy', 'id_ID').format(tanggal);
    final int kelas = report['kelas'] ?? 0;
    final int hadir = report['jumlah_hadir'] ?? 0;
    final int tidakHadir = report['jumlah_tidak_hadir'] ?? 0;
    final List<String> muridTidakHadir = (report['nama_murid_tidak_hadir'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _cardBackgroundColor,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$hari, $tanggalFormatted',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Absensi Kelas $kelas',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Konfirmasi Hapus'),
                              content: const Text('Apakah Anda yakin ingin menghapus laporan ini?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Batal'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _deleteReport(reportId);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      tooltip: 'Hapus Laporan',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(label: 'Hadir', value: hadir.toString(), color: Colors.green),
                    _buildStatColumn(label: 'Tidak Hadir', value: tidakHadir.toString(), color: Colors.red),
                  ],
                ),
                if (muridTidakHadir.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildAbsentStudentList(muridTidakHadir),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsentStudentList(List<String> students) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          'Lihat Murid Tidak Hadir (${students.length})',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: students.map((name) => ListTile(
          title: Text(name),
          dense: true,
          leading: Icon(Icons.person_off_outlined, color: Colors.grey[600]),
        )).toList(),
      ),
    );
  }

  Widget _buildStatColumn({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Future<void> _deleteReport(int reportId) async {
    try {
      await Supabase.instance.client
          .from('riwayat_absen')
          .delete()
          .eq('id', reportId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _reportsFuture = _fetchReports();
          _weeklySummaryFuture = _fetchWeeklySummary();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus laporan: ${e.toString()}')),
        );
      }
    }
  }

}
