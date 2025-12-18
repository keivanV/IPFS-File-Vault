// lib/main.dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/file_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UploadedFileAdapter());
  await Hive.openBox<UploadedFile>('uploadedFiles');
  await Hive.openBox('settings');

  final filesBox = Hive.box<UploadedFile>('uploadedFiles');
  await filesBox.clear();

  if (filesBox.isEmpty) {
    final demoFiles = [
      UploadedFile(
        fileName: 'Encryption_Key.pdf',
        hash:
            'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        uploadUrl: 'https://filevault.app/share/enckey2025',
        uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        accessCount: 18,
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        sharePassword: 'key2025!',
        fileType: 'pdf',
      ),
      UploadedFile(
        fileName: 'Blockchain_Report.docx',
        hash: 'd4e5f6a7b8c9d0e1f2g3h4i5j6k7l8m9n0o1p2q3r4s5t6u7v8w9x0y1z2',
        uploadUrl: 'https://filevault.app/share/blockreport',
        uploadDate: DateTime.now().subtract(const Duration(days: 8)),
        accessCount: 35,
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        sharePassword: null,
        fileType: 'docx',
      ),
      UploadedFile(
        fileName: 'Secure_Photo.png',
        hash: 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6',
        uploadUrl: 'https://filevault.app/share/secphoto',
        uploadDate: DateTime.now().subtract(const Duration(days: 1)),
        accessCount: 52,
        expiryDate: null,
        sharePassword: 'photo!123',
        fileType: 'png',
      ),
      UploadedFile(
        fileName: 'Crypto_Archive.zip',
        hash:
            '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
        uploadUrl: 'https://filevault.app/share/cryptoarch',
        uploadDate: DateTime.now().subtract(const Duration(days: 15)),
        accessCount: 9,
        expiryDate: DateTime.now().subtract(const Duration(days: 2)),
        sharePassword: 'arch2025',
        fileType: 'zip',
      ),
      UploadedFile(
        fileName: 'Financial_Report_2025.xlsx',
        hash: 'f1e2d3c4b5a69788796a5b4c3d2e1f0a9b8c7d6e5f4g3h2i1j0k',
        uploadUrl: 'https://filevault.app/share/finreport25',
        uploadDate: DateTime.now().subtract(const Duration(days: 4)),
        accessCount: 22,
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        sharePassword: 'fin2025',
        fileType: 'xlsx',
      ),
      UploadedFile(
        fileName: 'Private_Notes.txt',
        hash:
            '9f8e7d6c5b4a392817161514131211100f0e0d0c0b0a09080706050403020100',
        uploadUrl: 'https://filevault.app/share/privnotes',
        uploadDate: DateTime.now().subtract(const Duration(days: 3)),
        accessCount: 41,
        expiryDate: null,
        sharePassword: null,
        fileType: 'txt',
      ),
      UploadedFile(
        fileName: 'Team_Presentation.pptx',
        hash:
            'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
        uploadUrl: 'https://filevault.app/share/teampres',
        uploadDate: DateTime.now().subtract(const Duration(days: 6)),
        accessCount: 28,
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        sharePassword: 'team2025',
        fileType: 'pptx',
      ),
      UploadedFile(
        fileName: 'Security_Camera_Footage.mp4',
        hash:
            '11223344556677889900aabbccddeeff11223344556677889900aabbccddeeff',
        uploadUrl: 'https://filevault.app/share/camfootage',
        uploadDate: DateTime.now().subtract(const Duration(days: 10)),
        accessCount: 12,
        expiryDate: DateTime.now().add(const Duration(days: 1)),
        sharePassword: 'cam!2025',
        fileType: 'mp4',
      ),
      UploadedFile(
        fileName: 'ID_Card_Scan.jpg',
        hash: 'aaabbbcccdddeeefff000111222333444555666777888999aaabbbcccdddeee',
        uploadUrl: 'https://filevault.app/share/idscan',
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
        accessCount: 19,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        sharePassword: 'idscan2025',
        fileType: 'jpg',
      ),
      UploadedFile(
        fileName: 'Backup_Database.sql',
        hash: '000fff111eee222ddd333ccc444bbb555aaa666999888777666555444333222',
        uploadUrl: 'https://filevault.app/share/dbbackup',
        uploadDate: DateTime.now().subtract(const Duration(days: 20)),
        accessCount: 5,
        expiryDate: DateTime.now().subtract(const Duration(days: 5)),
        sharePassword: 'db!backup',
        fileType: 'sql',
      ),
    ];

    for (var file in demoFiles) {
      await filesBox.add(file);
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    final settingsBox = Hive.box('settings');
    _isDarkMode = settingsBox.get('darkMode', defaultValue: true) as bool;
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    Hive.box('settings').put('darkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Vault',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Vazirmatn',
        textTheme: const TextTheme().apply(fontFamily: 'Vazirmatn'),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.amber,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.amber),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Vazirmatn',
        textTheme: const TextTheme()
            .apply(fontFamily: 'Vazirmatn', bodyColor: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.amber,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.amber),
        ),
        useMaterial3: true,
      ),
      home: HomePage(isDarkMode: _isDarkMode, toggleTheme: _toggleTheme),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final void Function(bool) toggleTheme;

  const HomePage(
      {super.key, required this.isDarkMode, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Box<UploadedFile> _filesBox;
  late final Box _settingsBox;
  int _currentIndex = 0;

  String _searchQuery = '';
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _filesBox = Hive.box<UploadedFile>('uploadedFiles');
    _settingsBox = Hive.box('settings');
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

  Future<void> _generateQR(String data) async {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AlertDialog(
          backgroundColor: widget.isDarkMode ? Colors.black87 : Colors.white,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('QR کد لینک اشتراک فایل',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber)),
                const SizedBox(height: 20),
                SizedBox(
                  width: 280,
                  height: 280,
                  child: QrImageView(
                    data: data,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('بستن'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateCertificate(UploadedFile file) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) => pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Secure File Upload Certificate',
                    style: pw.TextStyle(
                        fontSize: 34,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber900)),
                pw.SizedBox(height: 30),
                pw.Container(
                  padding: const pw.EdgeInsets.all(25),
                  decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(color: PdfColors.amber900, width: 4),
                      borderRadius: pw.BorderRadius.circular(20)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(children: [
                        pw.Text('File Name: ',
                            style: pw.TextStyle(fontSize: 20)),
                        pw.Text(file.fileName,
                            style: pw.TextStyle(
                                fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      ]),
                      pw.SizedBox(height: 15),
                      pw.Text('SHA-256 Hash:',
                          style: pw.TextStyle(fontSize: 18)),
                      pw.Text(file.hash, style: pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 15),
                      pw.Text('Share Link:', style: pw.TextStyle(fontSize: 18)),
                      pw.Text(file.uploadUrl,
                          style: pw.TextStyle(
                              fontSize: 11, color: PdfColors.amber)),
                      pw.SizedBox(height: 15),
                      pw.Row(children: [
                        pw.Text('Upload Date: ',
                            style: pw.TextStyle(fontSize: 18)),
                        pw.Text(
                            DateFormat('yyyy/MM/dd - HH:mm')
                                .format(file.uploadDate),
                            style: pw.TextStyle(fontSize: 18)),
                      ]),
                      pw.SizedBox(height: 15),
                      pw.Row(children: [
                        pw.Text('Access Count: ',
                            style: pw.TextStyle(fontSize: 20)),
                        pw.Text(file.accessCount.toString(),
                            style: pw.TextStyle(
                                fontSize: 28,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.amber900)),
                      ]),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Text('This is a demo version and showcases all features',
                    style:
                        pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                pw.SizedBox(height: 10),
                pw.Text('File Vault - Secure File Storage and Sharing',
                    style:
                        pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
              ],
            ),
          ),
        ),
      );

      await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: 'Certificate_${file.fileName.replaceAll(' ', '_')}.pdf');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('گواهی با موفقیت به اشتراک گذاشته شد!'),
          backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('خطا در تولید گواهی: $e'),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _accessAndDownloadFile(UploadedFile file, int index) async {
    setState(() {
      file.accessCount++;
      _filesBox.putAt(index, file);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'تعداد دسترسی فایل "${file.fileName}" افزایش یافت (${file.accessCount} بار)'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _dashboardCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
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
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDashboard(Box<UploadedFile> box) {
    int totalFiles = box.length;
    int totalAccesses =
        box.values.fold(0, (sum, file) => sum + file.accessCount);
    int expiredFiles = box.values
        .where((f) =>
            f.expiryDate != null && f.expiryDate!.isBefore(DateTime.now()))
        .length;

    List<UploadedFile> recentFiles = box.values.toList()
      ..sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
    recentFiles = recentFiles.take(5).toList();

    List<UploadedFile> mostAccessed = box.values.toList()
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
              Icons.folder_rounded, Colors.amber),
          _dashboardCard('کل دسترسی‌ها', totalAccesses.toString(),
              Icons.touch_app_rounded, Colors.amber[600]!),
          _dashboardCard(
              'میانگین دسترسی',
              totalFiles > 0
                  ? (totalAccesses / totalFiles).toStringAsFixed(1)
                  : '0',
              Icons.bar_chart_rounded,
              Colors.amber[800]!),
          _dashboardCard('فایل‌های منقضی شده', expiredFiles.toString(),
              Icons.timer_off, Colors.redAccent),
          const SizedBox(height: 50),
          const Text('فایل‌های اخیر',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber)),
          const SizedBox(height: 20),
          ...recentFiles.map((file) => _recentFileItem(file)),
          const SizedBox(height: 50),
          const Text('پر دسترسی‌ترین فایل‌ها',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber)),
          const SizedBox(height: 20),
          ...mostAccessed.map((file) => _mostAccessedItem(file)),
        ],
      ),
    );
  }

  Widget _recentFileItem(UploadedFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode
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
                        color:
                            widget.isDarkMode ? Colors.white : Colors.black87)),
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

  Widget _mostAccessedItem(UploadedFile file) {
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
                    color: widget.isDarkMode ? Colors.white : Colors.black87)),
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

  Widget _filterChip(String label, String type) {
    bool selected = _filterType == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filterType = type),
        backgroundColor: Colors.grey[800],
        selectedColor: Colors.amber,
        labelStyle: TextStyle(color: selected ? Colors.black : Colors.white),
      ),
    );
  }

  Widget _buildFilesPage(Box<UploadedFile> box) {
    final filteredFiles = box.values.where((file) {
      final matchesSearch =
          file.fileName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == 'all' || file.fileType == _filterType;
      return matchesSearch && matchesType;
    }).toList();

    if (filteredFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 120, color: Colors.amber.withOpacity(0.6)),
            const SizedBox(height: 30),
            const Text('فایلی یافت نشد',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber)),
            const SizedBox(height: 20),
            Text(
                _searchQuery.isEmpty && _filterType == 'all'
                    ? 'خزانه خالی است'
                    : 'معیارهای جستجو را تغییر دهید',
                style: const TextStyle(fontSize: 18, color: Colors.white70)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth < 400) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 800) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 3;
        }

        double childAspectRatio;
        if (constraints.maxWidth < 600) {
          childAspectRatio = 1.5;
        } else if (constraints.maxWidth < 900) {
          childAspectRatio = 1.1;
        } else {
          childAspectRatio = 1;
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'جستجوی فایل...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip('همه', 'all'),
                          _filterChip('PDF', 'pdf'),
                          _filterChip('Word', 'docx'),
                          _filterChip('PowerPoint', 'pptx'),
                          _filterChip('عکس', 'png'),
                          _filterChip('عکس', 'jpg'),
                          _filterChip('آرشیو', 'zip'),
                          _filterChip('ویدیو', 'mp4'),
                          _filterChip('اکسل', 'xlsx'),
                          _filterChip('متن', 'txt'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: AnimationLimiter(
                child: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: childAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final file = filteredFiles[index];
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        columnCount: crossAxisCount,
                        child: ScaleAnimation(
                          duration: const Duration(milliseconds: 375),
                          child: FadeInAnimation(
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FileDetailPage(
                                    file: file,
                                    isDarkMode: widget.isDarkMode,
                                    parentContext: context,
                                  ),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: widget.isDarkMode
                                        ? [Colors.grey[900]!, Colors.black]
                                        : [Colors.white, Colors.grey[100]!],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                      color: Colors.amber.withOpacity(0.6),
                                      width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.amber.withOpacity(0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6)),
                                  ],
                                ),
                                padding: EdgeInsets.all(
                                    constraints.maxWidth < 400 ? 12 : 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.amber.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          child: Icon(
                                              getFileIcon(file.fileType),
                                              size: 28,
                                              color: Colors.amber),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            file.fileName,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        physics: const ClampingScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _infoRow(Icons.fingerprint, 'هش',
                                                '${file.hash.substring(0, 12)}...'),
                                            _infoRow(
                                                Icons.access_time,
                                                'تاریخ',
                                                DateFormat('dd MMM')
                                                    .format(file.uploadDate)),
                                            if (file.expiryDate != null)
                                              _infoRow(
                                                file.expiryDate!.isBefore(
                                                        DateTime.now())
                                                    ? Icons.warning
                                                    : Icons.timer,
                                                'انقضا',
                                                file.expiryDate!.isBefore(
                                                        DateTime.now())
                                                    ? 'منقضی'
                                                    : '${file.expiryDate!.difference(DateTime.now()).inDays + 1} روز',
                                                color: file.expiryDate!
                                                        .isBefore(
                                                            DateTime.now())
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.touch_app,
                                                size: 16, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text('${file.accessCount}',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.amber)),
                                          ],
                                        ),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _smallActionButton(
                                                  Icons.qr_code_2_rounded,
                                                  () => _generateQR(
                                                      file.uploadUrl)),
                                              _smallActionButton(
                                                  Icons.verified,
                                                  () => _generateCertificate(
                                                      file)),
                                              _smallActionButton(
                                                  Icons.cloud_download_rounded,
                                                  () => _accessAndDownloadFile(
                                                      file,
                                                      box.values
                                                          .toList()
                                                          .indexOf(file))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filteredFiles.length,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _smallActionButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.amber, size: 26),
      splashRadius: 22,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
                  Text('اپلیکیشن ذخیره و اشتراک امن فایل',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text(
                      'قابلیت‌ها: جستجو، فیلتر، جزئیات فایل، QR کد، گواهی PDF، داشبورد پیشرفته',
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
            ValueListenableBuilder(
                valueListenable: _filesBox.listenable(),
                builder: (context, box, _) => _buildFilesPage(box)),
            ValueListenableBuilder(
                valueListenable: _filesBox.listenable(),
                builder: (context, box, _) => _buildDashboard(box)),
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
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.folder_open), label: 'فایل‌ها'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'داشبورد'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'تنظیمات'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? Colors.amber),
          const SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(
                  fontSize: 13,
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: widget.isDarkMode ? Colors.white : Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

IconData getFileIcon(String type) {
  switch (type.toLowerCase()) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'docx':
    case 'pptx':
      return Icons.description;
    case 'png':
    case 'jpg':
    case 'jpeg':
      return Icons.image;
    case 'zip':
    case 'rar':
      return Icons.archive;
    case 'mp4':
    case 'mov':
    case 'avi':
      return Icons.videocam;
    case 'xlsx':
    case 'xls':
      return Icons.table_chart;
    case 'txt':
    case 'log':
    case 'sql':
      return Icons.text_snippet;
    default:
      return Icons.insert_drive_file;
  }
}

class FileDetailPage extends StatelessWidget {
  final UploadedFile file;
  final bool isDarkMode;
  final BuildContext parentContext;

  const FileDetailPage({
    super.key,
    required this.file,
    required this.isDarkMode,
    required this.parentContext,
  });

  void _showQR(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AlertDialog(
          backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('QR کد لینک اشتراک فایل',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber)),
                const SizedBox(height: 20),
                SizedBox(
                  width: 280,
                  height: 280,
                  child: QrImageView(
                    data: file.uploadUrl,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('بستن'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareCertificate(BuildContext context) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) => pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Secure File Upload Certificate',
                    style: pw.TextStyle(
                        fontSize: 34,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber900)),
                pw.SizedBox(height: 30),
                pw.Container(
                  padding: const pw.EdgeInsets.all(25),
                  decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(color: PdfColors.amber900, width: 4),
                      borderRadius: pw.BorderRadius.circular(20)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(children: [
                        pw.Text('File Name: ',
                            style: pw.TextStyle(fontSize: 20)),
                        pw.Text(file.fileName,
                            style: pw.TextStyle(
                                fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      ]),
                      pw.SizedBox(height: 15),
                      pw.Text('SHA-256 Hash:',
                          style: pw.TextStyle(fontSize: 18)),
                      pw.Text(file.hash, style: pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 15),
                      pw.Text('Share Link:', style: pw.TextStyle(fontSize: 18)),
                      pw.Text(file.uploadUrl,
                          style: pw.TextStyle(
                              fontSize: 11, color: PdfColors.amber)),
                      pw.SizedBox(height: 15),
                      pw.Row(children: [
                        pw.Text('Upload Date: ',
                            style: pw.TextStyle(fontSize: 18)),
                        pw.Text(
                            DateFormat('yyyy/MM/dd - HH:mm')
                                .format(file.uploadDate),
                            style: pw.TextStyle(fontSize: 18)),
                      ]),
                      pw.SizedBox(height: 15),
                      pw.Row(children: [
                        pw.Text('Access Count: ',
                            style: pw.TextStyle(fontSize: 20)),
                        pw.Text(file.accessCount.toString(),
                            style: pw.TextStyle(
                                fontSize: 28,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.amber900)),
                      ]),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Text('This is a demo version',
                    style:
                        pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
              ],
            ),
          ),
        ),
      );

      await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: 'Certificate_${file.fileName.replaceAll(' ', '_')}.pdf');

      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(
            content: Text('گواهی با موفقیت به اشتراک گذاشته شد!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
            content: Text('خطا در تولید گواهی: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = file.expiryDate != null
        ? file.expiryDate!.difference(DateTime.now()).inDays + 1
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(file.fileName, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.black.withOpacity(0.9),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.black, Colors.grey[900]!]
                : [Colors.grey[100]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.amber, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.amber.withOpacity(0.2), blurRadius: 20)
                  ],
                ),
                child: Column(
                  children: [
                    Icon(getFileIcon(file.fileType),
                        size: 80, color: Colors.amber),
                    const SizedBox(height: 20),
                    Text(file.fileName,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    _detailRow(Icons.link, 'لینک اشتراک', file.uploadUrl),
                    _detailRow(Icons.fingerprint, 'هش SHA-256', file.hash),
                    _detailRow(Icons.calendar_today, 'تاریخ آپلود',
                        DateFormat('yyyy/MM/dd HH:mm').format(file.uploadDate)),
                    _detailRow(Icons.touch_app, 'تعداد دسترسی',
                        '${file.accessCount} بار'),
                    if (file.sharePassword != null)
                      _detailRow(
                          Icons.lock, 'رمز عبور لینک', file.sharePassword!,
                          color: Colors.redAccent),
                    if (daysLeft != null)
                      _detailRow(
                        daysLeft > 0 ? Icons.timer : Icons.warning,
                        'وضعیت انقضا',
                        daysLeft > 0 ? '$daysLeft روز باقی‌مانده' : 'منقضی شده',
                        color: daysLeft > 0 ? Colors.green : Colors.red,
                      ),
                    if (file.expiryDate == null)
                      _detailRow(
                          Icons.all_inclusive, 'انقضا', 'بدون محدودیت زمانی'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showQR(context),
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('QR کد'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _shareCertificate(context),
                    icon: const Icon(Icons.verified),
                    label: const Text('گواهی PDF'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: file.uploadUrl));
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                            content: Text('لینک کپی شد!'),
                            backgroundColor: Colors.green),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('کپی لینک'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.amber, size: 28),
          const SizedBox(width: 16),
          Text('$label: ',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(value, style: TextStyle(fontSize: 16, color: color))),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final bool isDarkMode;
  final void Function(bool) toggleTheme;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const SizedBox(height: 40),
          Card(
            elevation: 8,
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SwitchListTile(
                title: Row(
                  children: [
                    Icon(Icons.dark_mode_rounded,
                        size: 32, color: Colors.amber),
                    const SizedBox(width: 16),
                    Text(
                      'حالت تاریک',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'تغییر تم اپلیکیشن به حالت روشن یا تاریک',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                ),
                value: isDarkMode,
                onChanged: toggleTheme,
                activeColor: Colors.amber,
                activeTrackColor: Colors.amber.withOpacity(0.4),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 8,
            color: Colors.orange.withOpacity(0.15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.info_rounded, size: 80, color: Colors.orange[700]),
                  const SizedBox(height: 20),
                  Text(
                    'این نسخه دمو است',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'آپلود واقعی انجام نمی‌شود، اما تمام قابلیت‌های اپلیکیشن به صورت کامل نمایش داده شده است.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'درباره File Vault',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 8,
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security_rounded,
                          size: 50, color: Colors.amber),
                      const SizedBox(width: 16),
                      Text(
                        'File Vault',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'اپلیکیشن امن ذخیره و اشتراک فایل‌ها با قابلیت‌های پیشرفته:',
                    style: TextStyle(fontSize: 17, height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  ...[
                    'ذخیره امن فایل‌ها با هش SHA-256',
                    'جستجو و فیلتر پیشرفته',
                    'صفحه جزئیات کامل هر فایل',
                    'تولید QR کد برای اشتراک سریع',
                    'گواهی رسمی PDF با اطلاعات کامل',
                    'داشبورد آماری جامع',
                    'پشتیبانی از انواع فرمت‌های فایل',
                    'انقضای لینک و رمزگذاری دسترسی',
                  ].map((feature) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle,
                                size: 20, color: Colors.amber),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'نسخه دمو ۱.۰.۰',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
