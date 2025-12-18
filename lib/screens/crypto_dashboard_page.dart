import 'dart:async'; // ← این خیلی مهم بود!
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/file_model.dart';
import '../services/crypto_service.dart';

class CryptoDashboardPage extends StatefulWidget {
  final bool isDarkMode;

  const CryptoDashboardPage({super.key, required this.isDarkMode});

  @override
  State<CryptoDashboardPage> createState() => _CryptoDashboardPageState();
}

class _CryptoDashboardPageState extends State<CryptoDashboardPage> {
  List<Map<String, dynamic>> cryptoPrices = [];
  bool isLoading = true;
  late Box<UploadedFile> filesBox;

  @override
  void initState() {
    super.initState();
    filesBox = Hive.box<UploadedFile>('uploadedFiles');
    _loadPrices();

    // بروزرسانی خودکار هر 60 ثانیه
    Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) _loadPrices();
    });
  }

  Future<void> _loadPrices() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final prices = await CryptoService.fetchPrices();

    if (mounted) {
      setState(() {
        cryptoPrices = prices;
        isLoading = false;
      });
    }
  }

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final totalFiles = filesBox.length;
    final fvtBalance = totalFiles * 10.0; // هر فایل = 10 FVT

    final fvtCoin = cryptoPrices.firstWhere(
      (coin) => coin['symbol'] == 'FVT',
      orElse: () => {'price': 0.05, 'change': 0.0},
    );

    final double fvtPrice =
        (fvtCoin['price'] is num) ? fvtCoin['price'].toDouble() : 0.05;
    final double fvtChange =
        (fvtCoin['change'] is num) ? fvtCoin['change'].toDouble() : 0.0;

    // محاسبه مجموع دارایی به دلار
    final double totalBalanceUsd = cryptoPrices.fold(0.0, (sum, coin) {
      final double price =
          (coin['price'] is num) ? coin['price'].toDouble() : 0.0;
      if (coin['symbol'] == 'FVT') {
        return sum + (fvtBalance * price);
      }
      return sum + price; // فرض: ۱ واحد از هر ارز واقعی
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'کیف پول بلاکچین',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                '  به‌روزرسانی خودکار قیمت‌ها',
                style: TextStyle(fontSize: 14, color: Colors.green),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.sync,
                size: 16,
                color: isLoading ? Colors.amber : Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 30),

          // کارت مجموع دارایی
          Card(
            elevation: 8,
            color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'مجموع دارایی کیف پول',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '\$${NumberFormat('#,##0.00').format(totalBalanceUsd)}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'FileVault Token',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$fvtBalance FVT',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.amber),
                          ),
                          Text(
                            '≈ \$${NumberFormat('#,##0.00').format(fvtBalance * fvtPrice)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'تعداد فایل‌ها',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$totalFiles',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.amber),
                          ),
                          const Text(
                            'هر فایل = 10 FVT',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'قیمت لحظه‌ای ارزها',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadPrices,
                color: Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.amber))
          else
            ...cryptoPrices.map((coin) {
              final double price =
                  (coin['price'] is num) ? coin['price'].toDouble() : 0.0;
              final double change =
                  (coin['change'] is num) ? coin['change'].toDouble() : 0.0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                color: coin['symbol'] == 'FVT'
                    ? Colors.amber.withOpacity(0.1)
                    : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.withOpacity(0.2),
                    child: Icon(coin['icon'] as IconData,
                        color: Colors.amber, size: 30),
                  ),
                  title: Text(
                    '${coin['name']} (${coin['symbol']})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: coin['symbol'] == 'FVT' ? 19 : 18,
                    ),
                  ),
                  subtitle: coin['symbol'] == 'FVT'
                      ? const Text('توکن اختصاصی File Vault',
                          style: TextStyle(color: Colors.orange))
                      : const Text('تغییر ۲۴ ساعته'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${NumberFormat('#,##0.00').format(price)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${change > 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: change > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 40),
          const Text(
            'آخرین تراکنش‌های دمو',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
          ),
          const SizedBox(height: 16),

          // تراکنش‌های دمو — اصلاح شده
          ...[
            {
              'type': 'receive',
              'amount': 50.0,
              'currency': 'FVT',
              'date': DateTime.now().subtract(const Duration(hours: 1)),
              'address': 'fvt1abc123456789xyz',
              'desc': 'پاداش آپلود فایل'
            },
            {
              'type': 'receive',
              'amount': 0.001,
              'currency': 'BTC',
              'date': DateTime.now().subtract(const Duration(hours: 5)),
              'address': '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
              'desc': null
            },
            {
              'type': 'send',
              'amount': 100.0,
              'currency': 'FVT',
              'date': DateTime.now().subtract(const Duration(days: 1)),
              'address': 'fvt1def123456789000',
              'desc': 'انتقال به کیف پول دیگر'
            },
          ].map((tx) => Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx['type'] == 'receive'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    child: Icon(
                      tx['type'] == 'receive'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color:
                          tx['type'] == 'receive' ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    '${tx['type'] == 'receive' ? 'دریافت' : 'ارسال'} ${tx['amount']} ${tx['currency']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    tx['desc'] as String? ??
                        DateFormat('dd MMM yyyy - HH:mm')
                            .format(tx['date'] as DateTime),
                  ),
                  trailing: Text(
                    tx['type'] == 'receive'
                        ? 'از: ${_shortenAddress(tx['address'] as String)}'
                        : 'به: ${_shortenAddress(tx['address'] as String)}',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.end,
                  ),
                ),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
