import 'dart:ui';

import 'package:blockchain_file_app/models/file_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/services.dart';


import '../../utils/file_icons.dart';
import 'file_detail_page.dart';

class FilesPage extends StatefulWidget {
  final bool isDarkMode;

  const FilesPage({super.key, required this.isDarkMode});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  final Box<UploadedFile> _filesBox = Hive.box<UploadedFile>('uploadedFiles');
  String _searchQuery = '';
  String _filterType = 'all';

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
                    border: pw.Border.all(color: PdfColors.amber900, width: 4),
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(children: [
                        pw.Text('File Name: ',
                            style: pw.TextStyle(fontSize: 20)),
                        pw.Text(file.fileName,
                            style: pw.TextStyle(
                                fontSize: 20, fontWeight: pw.FontWeight.bold))
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
                            style: pw.TextStyle(fontSize: 18))
                      ]),
                      pw.SizedBox(height: 15),
                      pw.Row(children: [
                        pw.Text('Access Count: ',
                            style: pw.TextStyle(fontSize: 20)),
                        pw.Text(file.accessCount.toString(),
                            style: pw.TextStyle(
                                fontSize: 28,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.amber900))
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
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: widget.isDarkMode ? Colors.white : Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _filesBox.listenable(),
      builder: (context, box, _) {
        final filteredFiles = box.values.where((file) {
          final matchesSearch =
              file.fileName.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesType =
              _filterType == 'all' || file.fileType == _filterType;
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
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth < 600
                ? 1
                : constraints.maxWidth < 1200
                    ? 2
                    : 3;
            double childAspectRatio = constraints.maxWidth < 600
                ? 1.5
                : constraints.maxWidth < 900
                    ? 1.1
                    : 1;

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
                          final fileIndex = box.values.toList().indexOf(file);

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
                                          isDarkMode: widget.isDarkMode),
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
                                            color:
                                                Colors.amber.withOpacity(0.15),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6))
                                      ],
                                    ),
                                    padding: EdgeInsets.all(
                                        constraints.maxWidth < 400 ? 12 : 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: Colors.amber
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16)),
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            physics:
                                                const ClampingScrollPhysics(),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _infoRow(
                                                    Icons.fingerprint,
                                                    'هش',
                                                    '${file.hash.substring(0, 12)}...'),
                                                _infoRow(
                                                    Icons.access_time,
                                                    'تاریخ',
                                                    DateFormat('dd MMM').format(
                                                        file.uploadDate)),
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
                                                    size: 16,
                                                    color: Colors.amber),
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
                                                children: [
                                                  _smallActionButton(
                                                      Icons.qr_code_2_rounded,
                                                      () => _generateQR(
                                                          file.uploadUrl)),
                                                  _smallActionButton(
                                                      Icons.verified,
                                                      () =>
                                                          _generateCertificate(
                                                              file)),
                                                  _smallActionButton(
                                                      Icons
                                                          .cloud_download_rounded,
                                                      () =>
                                                          _accessAndDownloadFile(
                                                              file, fileIndex)),
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
      },
    );
  }
}
