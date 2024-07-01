import 'package:bnb_test_app/constants.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class TokenService {
  final Web3Client _client;

  TokenService() : _client = Web3Client(activeRPC, http.Client());

  Future<Map<String, dynamic>> importToken(
      String tokenAddress, String walletAddress) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(bep20Abi, 'BEP20'),
      EthereumAddress.fromHex(tokenAddress),
    );

    final nameFunction = contract.function('name');
    final symbolFunction = contract.function('symbol');
    final decimalsFunction = contract.function('decimals');
    final balanceFunction = contract.function('balanceOf');

    final name = await _client
        .call(contract: contract, function: nameFunction, params: []);
    final symbol = await _client
        .call(contract: contract, function: symbolFunction, params: []);
    final decimals = await _client
        .call(contract: contract, function: decimalsFunction, params: []);
    final balance = await _client.call(
        contract: contract,
        function: balanceFunction,
        params: [EthereumAddress.fromHex(walletAddress)]);

    final bigIntBalance = balance[0] as BigInt;
    final bigIntDecimals =
        BigInt.from(10).pow(int.parse(decimals[0].toString()));
    final balanceFormatted = bigIntBalance / bigIntDecimals;

    return {
      'name': name[0],
      'symbol': symbol[0],
      'decimals': decimals[0].toString(),
      'balance': balanceFormatted.toStringAsFixed(4),
    };
  }

  Future<String> sendToken(String tokenAddress, String fromAddress,
      String toAddress, String amount, String privateKey, int decimals) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(bep20Abi, 'BEP20'),
      EthereumAddress.fromHex(tokenAddress),
    );

    final transferFunction = contract.function('transfer');
    final bigIntAmount = BigInt.parse(amount) * BigInt.from(10).pow(decimals);

    final credentials = EthPrivateKey.fromHex(privateKey);

    final transaction = Transaction.callContract(
      contract: contract,
      function: transferFunction,
      parameters: [EthereumAddress.fromHex(toAddress), bigIntAmount],
    );

    final result = await _client.sendTransaction(
      credentials,
      transaction,
      chainId: null,
      fetchChainIdFromNetworkId: true,
    );

    return result;
  }
}

const String bep20Abi = '''
[
    {"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"type":"function"},
    {"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"},
    {"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"},
    {"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"},
    {"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"type":"function"}
]
''';
