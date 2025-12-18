import 'package:blockchain_file_app/models/file_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';


import '../../utils/file_icons.dart';

class DashboardPage extends StatelessWidget {
  final bool isDarkMode;

  const DashboardPage({super.key, required this.isDarkMode});

  Widget _dashboardCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.7), width: 2),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: color),
          const SizedBox(height: 16),
          Text(value,
              style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.black54),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _recentFileItem(UploadedFile file, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(getFileIcon(file.fileType), size: 36, color: Colors.amber),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.fileName,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateFormat('dd MMM').format(file.uploadDate),
                  style: const TextStyle(color: Colors.amber, fontSize: 14)),
              Text('${file.accessCount} دسترسی',
                  style: const TextStyle(color: Colors.amber, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mostAccessedItem(UploadedFile file, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.amber.withOpacity(0.2), Colors.transparent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, size: 36, color: Colors.amber[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Text(file.fileName,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
          ),
          Text('${file.accessCount} دسترسی',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<UploadedFile>('uploadedFiles');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, _, __) {
        int totalFiles = box.length;
        int totalAccesses =
            box.values.fold(0, (sum, file) => sum + file.accessCount);
        int expiredFiles = box.values
            .where((f) =>
                f.expiryDate != null && f.expiryDate!.isBefore(DateTime.now()))
            .length;

        List<UploadedFile> recentFiles = List.from(box.values)
          ..sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
        recentFiles = recentFiles.take(5).toList();

        List<UploadedFile> mostAccessed = List.from(box.values)
          ..sort((a, b) => b.accessCount.compareTo(a.accessCount));
        mostAccessed = mostAccessed.take(4).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text('نمای کلی فایل‌های شما',
                  style: TextStyle(fontSize: 18, color: Colors.amber[700])),
              const SizedBox(height: 30),
              _dashboardCard('تعداد فایل‌ها', totalFiles.toString(),
                  Icons.folder_rounded, Colors.amber, isDarkMode),
              _dashboardCard('کل دسترسی‌ها', totalAccesses.toString(),
                  Icons.touch_app_rounded, Colors.amber[600]!, isDarkMode),
              _dashboardCard(
                  'میانگین دسترسی',
                  totalFiles > 0
                      ? (totalAccesses / totalFiles).toStringAsFixed(1)
                      : '0',
                  Icons.bar_chart_rounded,
                  Colors.amber[800]!,
                  isDarkMode),
              _dashboardCard('فایل‌های منقضی شده', expiredFiles.toString(),
                  Icons.timer_off, Colors.redAccent, isDarkMode),
              const SizedBox(height: 50),
              const Text('فایل‌های اخیر',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber)),
              const SizedBox(height: 20),
              ...recentFiles.map((file) => _recentFileItem(file, isDarkMode)),
              const SizedBox(height: 50),
              const Text('پر دسترسی‌ترین فایل‌ها',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber)),
              const SizedBox(height: 20),
              ...mostAccessed
                  .map((file) => _mostAccessedItem(file, isDarkMode)),
            ],
          ),
        );
      },
    );
  }
}
