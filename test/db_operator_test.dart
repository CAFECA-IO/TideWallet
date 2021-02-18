import 'package:flutter_test/flutter_test.dart';

import '../lib/database/entity/currency.dart';
import '../lib/database/db_operator.dart';
import '../lib/database/entity/account.dart';
import '../lib/database/entity/user.dart';

void main() {
  const String keystore =
      '{"address":"8d9bd81d0f01ad20232a89952b1abeffa9c11493","crypto":{"cipher":"aes-128-ctr","ciphertext":"111a639bafc9d35d1ae929fd6521025d9d580226e236f0ac2f3f1cfad18b7384","cipherparams":{"iv":"9f3420fe3fae6c1f06530378dcd93ced"},"mac":"7da001aadbe6c32afa4deeac1ce52823b422ba0f10ab3176892636ef466d1b0d","kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"r":1,"p":8,"salt":"70b3d4a31d4bfffe69e572c6701a4920d4534387f7af72fbdbdc83a1d4c8dad6"}},"id":"f6f83b1b-466b-4c7b-b7ed-033322224cc5","version":3}';
  DBOperator opt = DBOperator();

  setUpAll(() async {
    await DBOperator().init(inMemory: true);
  });

  tearDownAll(() async {
    await DBOperator().down();
  });
  group('database tests', () {
    group('user', () {
      test('find user', () async {
        UserEntity _user = UserEntity(
            '1qaz2wsx', keystore, 'password_hash1qaz2wsx', 'saltxyz', false);
        await opt.userDao.insertUser(_user);

        final actual = await opt.userDao.findUser();
        expect(actual, equals(_user));
      });
    });

    group('account', () {
      const accounts = [
        {
          "acount_id": "xxxxxxxx1",
          "blockchain_id": "80000000",
          "currency_id": "5b1ea92e584bf50020130615",
          "balance": "1000",
          "purpose": 44,
          "account_index": "0"
        },
        {
          "acount_id": "xxxxxxxx2",
          "blockchain_id": "80000000",
          "currency_id": "5b1ea92e584bf50020130615",
          "balance": "1000",
          "purpose": 44,
          "account_index": "0"
        }
      ];

      final currencies = [
        {
          "token_id": "5c0009411e24e600214f0eb1",
          "blockchain_id": "80000060",
          "name": "USD Coin",
          "symbol": "USDC",
          "type": 2,
          "publish": true,
          "decimals": 2,
          "total_supply": "5,767,712,364",
          "contract": "0x123456789...",
          "balance": "1000"
        },
        {
          "token_id": "5b1ea92e584bf50020130b28",
          "blockchain_id": "80000060",
          "name": "Dai",
          "symbol": "DAI",
          "type": 2,
          "publish": true,
          "decimals": 2,
          "total_supply": "1,619,686,135",
          "contract": "0x123456789...",
          "balance": "1000"
        }
      ];

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
              (c) => CurrencyEntity(
                  currencyId: c['token_id'],
                  name: c['name'],
                  coinType: 60,
                  totalSupply: c['total_supply'],
                  contract: c['contract'],
                  decimals: c['decimals'],
                  address: c['contract']),
            )
            .toList();
        List<int> _result = await opt.currencyDao.insertCurrencies(_currencies);

        expect(_result.length, _currencies.length);
      });
    });
  });
}
