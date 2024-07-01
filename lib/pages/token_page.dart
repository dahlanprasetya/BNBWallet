import 'package:bnb_test_app/services/token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class TokenImportPage extends StatefulWidget {
  @override
  _TokenImportPageState createState() => _TokenImportPageState();
}

class _TokenImportPageState extends State<TokenImportPage> {
  final _addressController = TextEditingController();
  final _walletAddressController = TextEditingController();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _privateKeyController = TextEditingController();
  final _tokenService = TokenService();

  Map<String, dynamic>? _tokenData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BEP-20 Token Manager')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Token Address',
                hintText: 'Enter BEP-20 token address',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _walletAddressController,
              decoration: const InputDecoration(
                labelText: 'Wallet Address',
                hintText: 'Enter your wallet address',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _importToken,
              child: const Text('Import Token'),
            ),
            const SizedBox(height: 16),
            if (_tokenData != null) ...[
              _buildTokenInfo(),
              const SizedBox(height: 16),
              _buildSendTokenForm(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTokenInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Token Name: ${_tokenData!['name']}',
                style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(height: 8),
            Text('Token Symbol: ${_tokenData!['symbol']}',
                style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(height: 8),
            Text('Decimals: ${_tokenData!['decimals']}',
                style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(height: 8),
            Text('Balance: ${_tokenData!['balance']} ${_tokenData!['symbol']}',
                style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }

  Widget _buildSendTokenForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient Address',
                hintText: 'Enter recipient wallet address',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount to send',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _privateKeyController,
              decoration: const InputDecoration(
                labelText: 'Private Key',
                hintText: 'Enter your private key',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendToken,
              child: const Text('Send Token'),
            ),
          ],
        ),
      ),
    );
  }

  void _importToken() async {
    if (_addressController.text.isEmpty ||
        _walletAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter both token and wallet addresses')),
      );
      return;
    }

    try {
      final data = await _tokenService.importToken(
          _addressController.text, _walletAddressController.text);
      setState(() {
        _tokenData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing token: ${e.toString()}')),
      );
    }
  }

  void _sendToken() async {
    if (_tokenData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please import a token first')),
      );
      return;
    }

    if (_recipientController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _privateKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final txHash = await _tokenService.sendToken(
          _addressController.text,
          _walletAddressController.text,
          _recipientController.text,
          _amountController.text,
          _privateKeyController.text,
          int.parse(_tokenData!['decimals']));

      // Show dialog with BscScan link
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Transaction Sent'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Transaction Hash: https://testnet.bscscan.com/tx/$txHash',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: txHash));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Transaction hash copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }

      // Refresh token data after sending
      _importToken();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending token: ${e.toString()}')),
      );
    }
  }

  void _launchUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
