import 'package:decimal/decimal.dart';
import 'package:rxdart/rxdart.dart';

import '../constants/account_config.dart';
import '../models/account.model.dart';
import '../services/account_service.dart';
import '../services/account_service_base.dart';
import '../services/ethereum_service.dart';
import '../mock/endpoint.dart';

class AccountCore {
  PublishSubject<AccountMessage> messenger;
  bool _isInit = false;
  List<AccountService> _services = [];
  List<Currency> accounts = [];
  Map<ACCOUNT, List<Currency>> currencies = {};

  static final AccountCore _instance = AccountCore._internal();
  factory AccountCore() => _instance;

  AccountCore._internal();

  bool get isInit => _isInit;

  setMessenger() {
    messenger = PublishSubject<AccountMessage>();
  }

  init() async {
    //
    _isInit = true;
    await _initAccounts();
  }

  _initAccounts() async {
    AccountService _service = AccountServiceBase();
    // TODO: Get amount in DB
    for (var value in ACCOUNT.values) {
      if (ACCOUNT_LIST[value] != null) {
        Currency _currency = Currency.fromMap(ACCOUNT_LIST[value]);
        Decimal fiat = Decimal.tryParse(_currency.fiat);

        this.currencies[value] = [];
        this.currencies[value].add(_currency);

        if (value == ACCOUNT.ETH) {
          List<Map> result = await getETHTokens();
          List<Currency> tokenList =
              result.map((e) => Currency.fromMap(e)).toList();
          tokenList.forEach((tk) {
            fiat += Decimal.tryParse(tk.fiat);
          });
          this.currencies[value] = this.currencies[value].sublist(0, 1) + tokenList;

          AccountService ethService = EthereumService(_service);
          this._services.add(ethService);
          ethService.start();
        }

        this.messenger.add(
            AccountMessage(evt: ACCOUNT_EVT.OnUpdateAccount, value: _currency.copyWith(fiat: fiat.toString())));

        
      }
    }
  }

  close() {
    messenger.close();
  }

  String getAccountFiat(ACCOUNT type) {
    List<Currency> _currs = this.currencies[type];

     Decimal fiat = Decimal.zero;
      _currs.forEach((curr) {
        print('Fiat: ${curr.fiat}, Amount: ${curr.amount}');
        fiat += Decimal.tryParse(curr.fiat);
      });
     return fiat.toString();
  }
}
