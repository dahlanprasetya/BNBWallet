import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BNB Wallet')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/import'),
              child: Text('Import Wallet'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/token'),
              child: Text('Import Token'),
            ),
          ],
        ),
      ),
    );
  }
}