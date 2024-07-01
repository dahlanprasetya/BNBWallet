import 'package:bnb_test_app/pages/token_page.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/import_page.dart';
import 'pages/wallet_page.dart';
import 'services/wallet_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BNB Wallet App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
      routes: {
        '/import': (context) => ImportPage(),
        '/wallet': (context) => WalletPage(),
        '/token': (context) => TokenImportPage(),
      },
    );
  }
}