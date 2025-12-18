import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final bool isDarkMode;
  final void Function(bool) toggleTheme;

  const SettingsPage(
      {super.key, required this.isDarkMode, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
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
                    Text('حالت تاریک',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('تغییر تم اپلیکیشن به حالت روشن یا تاریک',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                ),
                value: isDarkMode,
                onChanged: toggleTheme,
                activeColor: Colors.amber,
                activeTrackColor: Colors.amber.withOpacity(0.4),
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
                  Text('این نسخه دمو است',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800])),
                  const SizedBox(height: 16),
                  Text(
                      'آپلود واقعی انجام نمی‌شود، اما تمام قابلیت‌های اپلیکیشن به صورت کامل نمایش داده شده است.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, height: 1.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text('درباره File Vault',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber)),
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
                      Text('File Vault',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                      'اپلیکیشن امن ذخیره و اشتراک فایل‌ها با قابلیت‌های پیشرفته:',
                      style: TextStyle(fontSize: 17, height: 1.6)),
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
                                child: Text(feature,
                                    style: TextStyle(fontSize: 16))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 20),
                  Center(
                      child: Text('نسخه دمو ۱.۰.۰',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic))),
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
