import 'package:decimal/decimal.dart';

import 'account.model.dart';

class Investment {
  final String id;
  // TODO
  final List<InvestAccount> accounts;
  final String name;
  final String iconUrl;

  Investment({this.id, this.accounts, this.name, this.iconUrl});

  // TODO fromMap
}

class InvestAccount {
  final Decimal deposited;
  final Decimal totalYield;
  final Decimal yesterdayYield;
  final Decimal rate;
  final String address;
  final Currency account;
  final String name;

  InvestAccount({
    this.deposited,
    this.totalYield,
    this.yesterdayYield,
    this.rate,
    this.address,
    this.account,
    this.name,
  });

  InvestAccount copyWith({
    Decimal deposited,
    Decimal totalYield,
    Decimal yesterdayYield,
    Decimal rate,
    String address,
    Currency account,
    String name,
  }) {
    return InvestAccount(
      deposited: deposited ?? this.deposited,
      totalYield: totalYield ?? this.totalYield,
      yesterdayYield: yesterdayYield ?? this.yesterdayYield,
      rate: rate ?? this.rate,
      address: address ?? this.address,
      account: account ?? this.account,
      name: name ?? this.name,
    );
  }

  // TODO fromMap

}
