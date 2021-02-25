import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tidewallet3/repositories/transaction_repository.dart';
import 'package:tidewallet3/constants/account_config.dart';
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
  DBOperator opt = DBOperator();

  setUpAll(() async {
    await DBOperator().init(inMemory: true);
  });

  tearDownAll(() async {
    await DBOperator().down();
  });
  group('Bitcoin Transaction test', () {
    test('findAllJoinedUtxosById test', () async {
      List<JoinUtxo> utxos =
          await opt.utxoDao.findAllJoinedUtxosById('currencyId');
      expect(utxos, []);
    });
    test('insertUtxo test', () async {
      const accounts = [
        {
          "account_id": "8e951597-e720-424b-83ec-be57c2451a99",
          "blockchain_id": "80000001",
          "network_id": 0,
          "currency_id": "8e1ea17f-38f5-42ab-a24b-82bf8abc851b",
          "balance": "0.01033221",
          "publish": false,
          "account_index": "0"
        }
      ];
      List<AccountEntity> _accounts = accounts
          .map(
            (acc) => AccountEntity(
              accountId: acc['account_id'],
              userId: 'userId',
            ),
          )
          .toList();
      await opt.accountDao.insertAccounts(_accounts);
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
      List<CurrencyEntity> _currencies = currencies
          .map(
            (c) => CurrencyEntity.fromJson(c),
          )
          .toList();
      await opt.currencyDao.insertCurrencies(_currencies);
      AccountCore().setBitcoinAccountService();
      List<Map> accountsDetails = [
        {
          "blockchain_id": "80000001",
          "currency_id": "8e1ea17f-38f5-42ab-a24b-82bf8abc851b",
          "account_id": "8e951597-e720-424b-83ec-be57c2451a99",
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
      List<AccountCurrencyEntity> _accountsDetails = accountsDetails
          .map(
            (c) => AccountCurrencyEntity(
                accountcurrencyId: c['account_id'] ??
                    c['account_token_id'], // TODO: Change name
                accountId: c['account_id'],
                numberOfUsedExternalKey: c['number_of_external_key'],
                numberOfUsedInternalKey: c['number_of_internal_key'],
                balance: c['balance'],
                currencyId: c['currency_id'] ?? c['token_id'],
                lastSyncTime: DateTime.now().millisecondsSinceEpoch),
          )
          .toList();

      await DBOperator().accountCurrencyDao.insertCurrencies(_accountsDetails);
      List<JoinUtxo> utxos =
          await opt.utxoDao.findAllJoinedUtxosById('currencyId');
      Log.warning('hex.encode(Uint8List(0)): ${hex.encode(Uint8List(0))}');

      if (utxos.isEmpty) {
        UtxoEntity _utxo = UtxoEntity.fromUnspentUtxo(UnspentTxOut(
          id: '9715a35201ba82bd434840e0cc4b0fb8f0497fd7bb45e8b6c3fb4d457c43e179',
          accountcurrencyId: 'currencyId',
          txId:
              '9715a35201ba82bd434840e0cc4b0fb8f0497fd7bb45e8b6c3fb4d457c43e179',
          vout: 0,
          type: BitcoinTransactionType.WITNESS_V0_KEYHASH,
          data: Uint8List(0),
          amount: Decimal.parse('0.01033221'),
          chainIndex: 0,
          keyIndex: 0,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          locked: false,
        ));
        await opt.utxoDao.insertUtxo(_utxo);
      }
      // utxos = await opt.utxoDao.findAllJoinedUtxosById('currencyId');
      // Log.warning('utxos: $utxos');
      // expect(utxos.isNotEmpty, true);

      final _utxos = await opt.utxoDao.findAllUtxos();
      Log.warning('_utxos: $_utxos');
      expect(_utxos.isNotEmpty, true);
    });
    test('Bitcoin prepareTransaction test', () async {
      TransactionRepository _repo = TransactionRepository();
      _repo.setCurrency(Currency(accountType: ACCOUNT.BTC, id: 'currencyId'));
      List result = await _repo.prepareTransaction('tideWallet3',
          'tb1qfye0jy9ux5qwt4d4mczknz6ydt662k869dw7qa', Decimal.parse('0.0002'),
          fee: Decimal.parse('0.00016703'));
      BitcoinTransaction transaction = result[0];
      Log.debug('transaction: ${hex.encode(transaction.serializeTransaction)}');
    });
  });
}
