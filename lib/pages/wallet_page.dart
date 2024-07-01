import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final WalletService _walletService = WalletService();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();

  String _address = '';
  String _balance = 'Unknown';

  @override
  void initState() {
    super.initState();
    _loadWalletInfo();
  }

  void _loadWalletInfo() async {
    final address = await _walletService.getAddress();
    final balance = await _walletService.getBalance();
    setState(() {
      _address = address;
      _balance = balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wallet')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Address: $_address'),
            Text('Balance: $_balance BNB'),
            TextFormField(
              controller: _recipientController,
              decoration: InputDecoration(labelText: 'Recipient Address'),
            ),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount (BNB)'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _transfer,
              child: Text('Transfer BNB'),
            ),
          ],
        ),
      ),
    );
  }

  void _transfer() async {
    try {
      await _walletService.transfer(
        _recipientController.text,
        double.parse(_amountController.text),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transfer successful')),
      );
      _loadWalletInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transfer failed: ${e.toString()}')),
      );
    }
  }
}