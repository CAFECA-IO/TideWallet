import '../models/bitcoin_transaction.model.dart';
import '../constants/account_config.dart';
import 'transaction_service.dart';
import 'transaction_service_decorator_bitcoin_based.dart';

class BitcoinTransactionService
    extends BitcoinBasedTransactionServiceDecorator {
  BitcoinTransactionService(TransactionService service) : super(service) {
    this.base = ACCOUNT.BTC;
    this.p2pkhAddressPrefixTestnet = 0x6F;
    this.p2pkhAddressPrefixMainnet = 0;
    this.p2shAddressPrefixTestnet = 0xC4;
    this.p2shAddressPrefixMainnet = 0x05;
    this.bech32HrpMainnet = 'bc';
    this.bech32HrpTestnet = 'tb';
    this.bech32Separator = '1';
    this.supportSegwit = true;
    this.segWitType = SegWitType.nativeSegWit; //TODO segwitType
  }

  // @override
  // Future<Uint8List> prepareTransaction(
  //     {String to, Decimal amount, Decimal fee, Uint8List message}) {
  //   // TODO: implement prepareTransaction
  //   throw UnimplementedError();
  // }

  // @override
  // Future<bool> verifyAddress(String address) {
  //   // TODO: implement verifyAddress
  //   throw UnimplementedError();
  // }
}
