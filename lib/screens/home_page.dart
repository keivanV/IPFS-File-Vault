import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/file_model.dart';
import 'files_page.dart';
import 'dashboard_page.dart';
import 'crypto_dashboard_page.dart'; // ← جدید
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final void Function(bool) toggleTheme;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Box<UploadedFile> _filesBox;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _filesBox = Hive.box<UploadedFile>('uploadedFiles');
  }

  Future<void> _uploadFile() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('در نسخه دمو امکان آپلود وجود ندارد.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('FILE VAULT'),
        backgroundColor: Colors.black.withOpacity(0.9),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'File Vault',
                applicationVersion: '1.0.0 (دمو)',
                applicationIcon:
                    const Icon(Icons.security, size: 60, color: Colors.amber),
                children: const [
                  Text('اپلیکیشن ذخیره و اشتراک امن فایل با قابلیت‌های بلاکچین',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text(
                      'قابلیت‌ها: فایل امن، داشبورد، کیف پول دمو، QR کد، گواهی PDF',
                      textAlign: TextAlign.center),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.isDarkMode
                ? [Colors.black, Colors.grey[900]!]
                : [Colors.grey[100]!, Colors.white],
          ),
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: [
            FilesPage(isDarkMode: widget.isDarkMode),
            DashboardPage(isDarkMode: widget.isDarkMode),
            CryptoDashboardPage(isDarkMode: widget.isDarkMode), // ← تب جدید
            SettingsPage(
                isDarkMode: widget.isDarkMode, toggleTheme: widget.toggleTheme),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _uploadFile,
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add, size: 32),
              label: const Text('آپلود فایل',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.folder_open), label: 'فایل‌ها'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'داشبورد'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'کیف پول'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'تنظیمات'),
        ],
      ),
    );
  }
}
