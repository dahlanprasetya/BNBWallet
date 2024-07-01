import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/wallet_service.dart';

class ImportPage extends StatefulWidget {
  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final _formKey = GlobalKey<FormState>();
  final _mnemonicController = TextEditingController();
  final _depthController = TextEditingController();
  final _privateKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Import Wallet')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _mnemonicController,
                decoration: InputDecoration(labelText: 'Mnemonic'),
              ),
              TextFormField(
                controller: _depthController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Depth',
                  hintText: 'Enter a number',
                ),
              ),
              ElevatedButton(
                onPressed: () => _importWallet(context, true),
                child: const Text('Import Mnemonic'),
              ),
              TextFormField(
                controller: _privateKeyController,
                decoration: InputDecoration(labelText: 'Private Key'),
              ),
              ElevatedButton(
                onPressed: () => _importWallet(context, false),
                child: const Text('Import Private Key'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _importWallet(BuildContext context, bool isMnemonic) async {
    final walletService = WalletService();
    bool notEmpty = true;
    if (isMnemonic) {
      if (_mnemonicController.text == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Failed to import wallet: [please enter the mnemonic phrase]')),
        );
        notEmpty = false;
      }
      if (notEmpty) {
        await walletService.importMnemonic(_mnemonicController.text, int.tryParse(_depthController.text));
      }
    } else {
      if (_privateKeyController.text == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Failed to import wallet: [please enter the private key]')),
        );
        notEmpty = false;
      }
      if (notEmpty) {
        await walletService.importPrivateKey(_privateKeyController.text);
      }
    }
    if (context.mounted && notEmpty) {
      Navigator.pushReplacementNamed(context, '/wallet');
    }
  }
}
