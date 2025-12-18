import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CryptoService {
  static final List<Map<String, dynamic>> coins = [
    {
      'id': 'btc-bitcoin',
      'symbol': 'BTC',
      'name': 'Bitcoin',
      'icon': Icons.currency_bitcoin
    },
    {
      'id': 'eth-ethereum',
      'symbol': 'ETH',
      'name': 'Ethereum',
      'icon': Icons.circle
    },
    {
      'id': 'sol-solana',
      'symbol': 'SOL',
      'name': 'Solana',
      'icon': Icons.sunny
    },
    {
      'id': 'bnb-binance-coin',
      'symbol': 'BNB',
      'name': 'Binance Coin',
      'icon': Icons.account_balance
    },
    {
      'id': 'ada-cardano',
      'symbol': 'ADA',
      'name': 'Cardano',
      'icon': Icons.credit_card
    },
    // توکن ساختگی ما
    {
      'id': 'fvt-filevault-token',
      'symbol': 'FVT',
      'name': 'FileVault Token',
      'icon': Icons.folder_special,
      'isFake': true
    },
  ];

  static Future<List<Map<String, dynamic>>> fetchPrices() async {
    final List<Map<String, dynamic>> result = [];

    // آیدی‌های واقعی برای درخواست
    final realCoinIds =
        coins.where((c) => c['isFake'] != true).map((c) => c['id']).join(',');

    final url = 'https://api.coinpaprika.com/v1/tickers?quotes=USD';

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        for (var coin in coins) {
          if (coin['isFake'] == true) {
            final fakeChange = ((DateTime.now().millisecond % 200) - 100) /
                10.0; // -10% تا +10%
            result.add({
              ...coin,
              'price': 0.05,
              'change': fakeChange,
            });
          } else {
            final ticker = data.firstWhere(
              (t) => t['id'] == coin['id'],
              orElse: () => null,
            );

            if (ticker != null) {
              final double price =
                  ticker['quotes']['USD']['price']?.toDouble() ?? 0.0;
              final double change =
                  ticker['quotes']['USD']['percent_change_24h']?.toDouble() ??
                      0.0;

              result.add({
                ...coin,
                'price': price,
                'change': change,
              });
            } else {
              result.add({
                ...coin,
                'price': 0.0,
                'change': 0.0,
              });
            }
          }
        }

        return result;
      }
    } catch (e) {
      print('Error fetching prices from CoinPaprika: $e');
    }

    // در صورت خطا، داده‌های دمو
    return coins
        .map((coin) => {
              ...coin,
              'price': coin['isFake'] == true ? 0.05 : 0.0,
              'change': 0.0,
            })
        .toList();
  }
}
