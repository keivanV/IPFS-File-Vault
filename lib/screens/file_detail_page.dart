import 'dart:ui';

import 'package:blockchain_file_app/models/file_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


import '../../utils/file_icons.dart';

class FileDetailPage extends StatelessWidget {
  final UploadedFile file;
  final bool isDarkMode;

  const FileDetailPage(
      {super.key, required this.file, required this.isDarkMode});

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('گواهی با موفقیت به اشتراک گذاشته شد!'),
          backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('خطا در تولید گواهی: $e'),
          backgroundColor: Colors.red));
    }
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
                          foregroundColor: Colors.black)),
                  ElevatedButton.icon(
                      onPressed: () => _shareCertificate(context),
                      icon: const Icon(Icons.verified),
                      label: const Text('گواهی PDF'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black)),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: file.uploadUrl));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('لینک کپی شد!'),
                          backgroundColor: Colors.green));
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
}
