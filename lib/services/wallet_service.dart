import 'dart:typed_data';

import 'package:bnb_test_app/constants.dart';
import 'package:web3dart/web3dart.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;

  WalletService._internal();

  final _storage = FlutterSecureStorage();
  Web3Client? _client;
  Credentials? _credentials;
  EthereumAddress? _address;

  Future<void> _initClient() async {
    _client ??=
        Web3Client(activeRPC, Client());
  }

  Uint8List bigIntToUint8List(BigInt bigInt) =>
      bigIntToByteData(bigInt).buffer.asUint8List();

  //help to get wallet data from seed
  ByteData bigIntToByteData(BigInt bigInt) {
    final data = ByteData((bigInt.bitLength / 8).ceil());
    var _bigInt = bigInt;

    for (var i = 1; i <= data.lengthInBytes; i++) {
      data.setUint8(data.lengthInBytes - i, _bigInt.toUnsigned(8).toInt());
      _bigInt = _bigInt >> 8;
    }
    return data;
  }

  // Future<void> importMnemonic(String mnemonic) async {
  //   const passphrase = '';
  //   final seed =
  //       wallet.mnemonicToSeed(mnemonic.split(' '), passphrase: passphrase);
  //   final master = wallet.ExtendedPrivateKey.master(seed, wallet.xprv);
  //   final root = master.forPath("m/44'/60'/0'/0/0");
  //   final privateKey =
  //       wallet.PrivateKey((root as wallet.ExtendedPrivateKey).key);
  //   final prikey_hex = bigIntToUint8List(privateKey.value)
  //       .map((i) => i.toRadixString(16))
  //       .toList();
  //   var PrivateKey_hex = '';
  //   prikey_hex.forEach((val) {
  //     // log(val);
  //     if (val.length < 2) {
  //       PrivateKey_hex += '0$val';
  //     } else {
  //       PrivateKey_hex += val;
  //     }
  //   });
  //   log('account_model add_new_account_from_mnemonic : PrivateKey_hex : $PrivateKey_hex');
  //   final publicKey = wallet.ethereum.createPublicKey(privateKey);
  //   log('account_model add_new_account_from_mnemonic : publicKey.value : ${publicKey.value}');
  //   final address = wallet.ethereum.createAddress(publicKey);
  //   log('account_model add_new_account_from_mnemonic : address : $address');
  //   _credentials = EthPrivateKey.fromHex(PrivateKey_hex);
  //   await _updateAddress();
  //   await _storage.write(
  //     key: 'private_key',
  //     value: ibip39.mnemonicToEntropy(mnemonic),
  //   );
  // }

  Future<void> importMnemonic(String mnemonic, int? depth) async {
    // Validate mnemonic
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic');
    }

    // Generate seed from mnemonic
    final seed = bip39.mnemonicToSeed(mnemonic);

    // Derive the private key using BIP44
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/60'/0'/0/$depth");

    if (child.privateKey == null) {
      throw Exception('Unable to derive private key');
    }

    final privateKey = HEX.encode(child.privateKey!);

    // Create credentials and update address
    _credentials = EthPrivateKey.fromHex(privateKey);
    await _updateAddress();

    // Store the private key securely
    await _storage.write(key: 'private_key', value: privateKey);
  }

  Future<void> importPrivateKey(String privateKey) async {
    _credentials = EthPrivateKey.fromHex(privateKey);
    await _updateAddress();
    await _storage.write(key: 'private_key', value: privateKey);
  }

  Future<void> _updateAddress() async {
    await _initClient();
    if (_credentials != null) {
      _address = _credentials!.address;
    }
  }

  Future<String> getAddress() async {
    if (_address == null) {
      String? privateKey = await _storage.read(key: 'private_key');
      if (privateKey != null) {
        await importPrivateKey(privateKey);
      }
    }
    return _address?.hexEip55 ?? 'Address not set';
  }

  Future<String> getBalance() async {
    await _initClient();
    if (_address != null) {
      EtherAmount balance = await _client!.getBalance(_address!);
      return balance.getValueInUnit(EtherUnit.ether).toString();
    }
    return 'Unknown';
  }

  Future<void> transfer(String recipient, double amount) async {
    await _initClient();
    if (_credentials != null && _address != null) {
      EthereumAddress recipientAddress = EthereumAddress.fromHex(recipient);
      EtherAmount value = EtherAmount.fromBase10String(
          EtherUnit.wei, (amount * 1e18).toInt().toString());

      await _client!.sendTransaction(
        _credentials!,
        Transaction(
          to: recipientAddress,
          value: value,
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true,
      );
    } else {
      throw Exception('Wallet not initialized');
    }
  }
}
