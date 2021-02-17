import '../constants/account_config.dart';
import 'transaction_service.dart';
import 'transaction_service_decorator_ethereum_based.dart';

class EthereumTransactionService
    extends EthereumBasedTransactionServiceDecorator {
  EthereumTransactionService(TransactionService service) : super(service) {
    this.base = ACCOUNT.ETH;
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
