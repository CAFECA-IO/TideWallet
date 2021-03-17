import 'package:rxdart/rxdart.dart';
import 'package:decimal/decimal.dart';

import '../models/investment.model.dart';
import '../models/account.model.dart';

import '../helpers/utils.dart';

// ++ ContractCore function 2021/3/17 Emily
// ++ Create MessageBuffer for Transaction 2021/3/17 Emily
class ContractCore {
  static final ContractCore _instance = ContractCore._internal();
  factory ContractCore() => _instance;

  ContractCore._internal();
}
