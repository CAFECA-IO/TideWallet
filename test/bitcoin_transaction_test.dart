import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tidewallet3/helpers/http_agent.dart';

import 'package:tidewallet3/repositories/transaction_repository.dart';
import 'package:tidewallet3/constants/account_config.dart';
import 'package:tidewallet3/database/entity/user.dart';
import 'package:tidewallet3/database/entity/utxo.dart';
import 'package:tidewallet3/database/entity/account.dart';
import 'package:tidewallet3/database/entity/currency.dart';
import 'package:tidewallet3/database/entity/account_currency.dart';
import 'package:tidewallet3/database/db_operator.dart';
import 'package:tidewallet3/models/account.model.dart';
import 'package:tidewallet3/models/bitcoin_transaction.model.dart';
import 'package:tidewallet3/models/utxo.model.dart';
import 'package:tidewallet3/helpers/logger.dart';
import 'package:tidewallet3/cores/account.dart';

void main() {
  const String keystore =
      '{"address":"8d9bd81d0f01ad20232a89952b1abeffa9c11493","crypto":{"cipher":"aes-128-ctr","ciphertext":"111a639bafc9d35d1ae929fd6521025d9d580226e236f0ac2f3f1cfad18b7384","cipherparams":{"iv":"9f3420fe3fae6c1f06530378dcd93ced"},"mac":"7da001aadbe6c32afa4deeac1ce52823b422ba0f10ab3176892636ef466d1b0d","kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"r":1,"p":8,"salt":"70b3d4a31d4bfffe69e572c6701a4920d4534387f7af72fbdbdc83a1d4c8dad6"}},"id":"f6f83b1b-466b-4c7b-b7ed-033322224cc5","version":3}';
  DBOperator opt = DBOperator();
  setUpAll(() async {
    await DBOperator().init(inMemory: true);
    AccountCore().setBitcoinAccountService();
  });

  tearDownAll(() async {
    await DBOperator().down();
  });
  group('Bitcoin Transaction test', () {
    const accounts = [
      {
        "account_id": "948c3b58-d1e4-45b2-afed-f3825256beda",
        "blockchain_id": "80000001",
        "network_id": 0,
        "currency_id": "8e1ea17f-38f5-42ab-a24b-82bf8abc851b",
        "balance": "0.01033221",
        "publish": false,
        "account_index": "0"
      }
    ];
    const currencies = [
      {
        "currency_id": "8e1ea17f-38f5-42ab-a24b-82bf8abc851b",
        "name": "Bitcoin Testnet",
        "symbol": "BTC",
        "type": 1,
        "publish": false,
        "decimals": 8,
        "exchange_rate": null,
        "icon":
            "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@9ab8d6934b83a4aa8ae5e8711609a70ca0ab1b2b/32/icon/btc.png"
      }
    ];
    List<Map> accountsDetails = [
      {
        "blockchain_id": "80000001",
        "currency_id": "8e1ea17f-38f5-42ab-a24b-82bf8abc851b",
        "account_id": "948c3b58-d1e4-45b2-afed-f3825256beda",
        "purpose": 44,
        "account_index": "0",
        "curve_type": 0,
        "balance": "0",
        "symbol": "BTC",
        "icon":
            "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@9ab8d6934b83a4aa8ae5e8711609a70ca0ab1b2b/32/icon/btc.png",
        "tokens": []
      }
    ];
    test('find user', () async {
      UserEntity _user = UserEntity(
          '1qaz2wsx', keystore, 'password_hash1qaz2wsx', 'saltxyz', false);
      await opt.userDao.insertUser(_user);

      final actual = await opt.userDao.findUser();
      expect(actual, equals(_user));
    });

    test('insert accounts', () async {
      final UserEntity user = await opt.userDao.findUser();

      List<AccountEntity> _accounts = accounts
          .map(
            (acc) => AccountEntity(
              accountId: acc['account_id'],
              userId: user.userId,
              // purpose: acc['purpose'],
              // accountIndex: int.tryParse(
              //   acc['account_index'],
              // ),
            ),
          )
          .toList();
      List<int> _result = await opt.accountDao.insertAccounts(_accounts);
      List<AccountEntity> actual = await opt.accountDao.findAllAccounts();

      expect(actual, equals(_accounts));
    });
    test('insert currencies', () async {
      List<CurrencyEntity> _currencies = currencies
          .map(
            (c) => CurrencyEntity.fromJson(c),
          )
          .toList();
      List<int> _result = await opt.currencyDao.insertCurrencies(_currencies);

      expect(_result.length, _currencies.length);
    });

    test('insert AccountCurrency', () async {
      int now = DateTime.now().millisecondsSinceEpoch;
      List<AccountCurrencyEntity> _accountsDetails = accountsDetails
          .map((c) => AccountCurrencyEntity.fromJson(c, c['accountId'], now))
          .toList();
      List<int> _result = await DBOperator()
          .accountCurrencyDao
          .insertCurrencies(_accountsDetails);

      expect(_result.length, _result.length);
    });

    test('findAllJoinedUtxosById test', () async {
      List<JoinUtxo> utxos =
          await opt.utxoDao.findAllJoinedUtxosById('currencyId');
      expect(utxos, []);
    });

    test('insertUtxo test', () async {
      List<JoinUtxo> utxos = await opt.utxoDao
          .findAllJoinedUtxosById('948c3b58-d1e4-45b2-afed-f3825256beda');
      Log.warning('hex.encode(Uint8List(0)): ${hex.encode(Uint8List(0))}');

      if (utxos.isEmpty) {
        UtxoEntity _utxo = UtxoEntity.fromUnspentUtxo(UnspentTxOut(
            id:
                'a54799e85b8477a24a213dc8969bd7827a112a71569aab11b3023ee7626ddbae',
            accountcurrencyId: "948c3b58-d1e4-45b2-afed-f3825256beda",
            txId:
                'a54799e85b8477a24a213dc8969bd7827a112a71569aab11b3023ee7626ddbae',
            vout: 1,
            type: BitcoinTransactionType.WITNESS_V0_KEYHASH,
            data: Uint8List(0),
            amount: Decimal.parse('0.01952035'),
            address: 'tb1qmgs58vsyc4st6u2h577a8scpe9y2kk92pg4pjh',
            chainIndex: 1,
            keyIndex: 0,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            locked: false,
            decimals: 8));
        await opt.utxoDao.insertUtxo(_utxo);
      }

      utxos = await opt.utxoDao
          .findAllJoinedUtxosById("948c3b58-d1e4-45b2-afed-f3825256beda");
      Log.warning('utxos: $utxos');
      utxos = await opt.utxoDao.findAllJoinedUtxos();
      Log.debug('utxos2: $utxos');
      Log.debug('utxos2: ${utxos[0].decimals}');
      Log.debug('utxos2: ${utxos[0].amount}');
      expect(utxos.isNotEmpty, true);
    });
    test('Bitcoin prepareTransaction test', () async {
      HTTPAgent().setToken(
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOiI5NTUxNGNkYy1hMzVmLTQwNzEtOTZhYy0yNDc4MGI2NmI2MjAiLCJpYXQiOjE2MTQzMjU5MTEsImV4cCI6MTY0NTg2MTkxMX0.nPQFCs-89hnns5njXIPPBNZQGfueWZUr9M5DErq2i4k');
      TransactionRepository _repo = TransactionRepository();
      _repo.setCurrency(Currency(
          accountType: ACCOUNT.BTC,
          id: '948c3b58-d1e4-45b2-afed-f3825256beda',
          decimals: 8,
          publish: false,
          amount: '0.01952035'));
      List result = await _repo.prepareTransaction('tideWallet3',
          'tb1q2cwlwck3ly9hlsx9r9qchhn6escc0jt8mn5eq5', Decimal.parse('0.0002'),
          fee: Decimal.parse('0.00016703'));
      BitcoinTransaction transaction = result[0];
      Log.debug('transaction: ${hex.encode(transaction.serializeTransaction)}');
    });
  });
}
