import '../models/transaction.model.dart';
import '../helpers/logger.dart';
import 'package:decimal/decimal.dart';

class SwapRepository {
  // ++ call ContractCore() to get messageButter 2021/3/17 Emily
  Decimal getTransactionFee(
    String from,
    String to,
    String amount,
    // ++ ContractType 2021/3/17 Emily
  ) {
    return Decimal.parse('0.000005');
    // ++ use account service to get Account transaction priority && gasLimit to cal Fee 2021/3/17 Emily
  }
}
