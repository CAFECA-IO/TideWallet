import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../repositories/account_repository.dart';
import 'transaction.screen.dart';
import 'receive.screen.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../blocs/fiat/fiat_bloc.dart';
import '../blocs/account_detail/account_detail_bloc.dart';
import '../widgets/appBar.dart';
import '../widgets/buttons/tertiary_button.dart';
import '../widgets/transaction_item.dart';

import '../helpers/formatter.dart';
import '../helpers/i18n.dart';
import '../theme.dart';

class AccountDetailScreen extends StatefulWidget {
  static const routeName = '/transaction-list';

  @override
  _AccountDetailScreenState createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  final t = I18n.t;
  late AccountDetailBloc _bloc;
  late AccountRepository _repo;

  @override
  void didChangeDependencies() {
    dynamic arg = ModalRoute.of(context)!.settings.arguments!;
    String accountId = arg["accountId"]!;
    _repo = Provider.of<AccountRepository>(context);

    _bloc = AccountDetailBloc(_repo)..add(GetAccountDetail(accountId));

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GeneralAppbar(
        title: '',
        routeName: AccountDetailScreen.routeName,
      ),
      body: BlocBuilder<AccountDetailBloc, AccountDetailState>(
          bloc: _bloc,
          builder: (context, state) {
            return (state is AccountDetailLoaded)
                ? Container(
                    child: Column(children: [
                      Container(
                        width: double.infinity,
                        // height: 300.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor
                            ],
                          ),
                        ),
                        child: Column(children: [
                          // Spacer(),
                          SizedBox(height: 100),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: MyColors.font_01,
                                shape: BoxShape.circle),
                            child: Image.network(
                              state.account.imgPath,
                              width: 32.0,
                              height: 32.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              state.account.symbol.toUpperCase(),
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                                '${Formatter.formatDecimal(state.account.balance)}',
                                style: Theme.of(context).textTheme.headline4),
                          ),
                          BlocBuilder<FiatBloc, FiatState>(
                              builder: (context, fiatState) {
                            return Text(
                              '${String.fromCharCode(0x2248)} ${state.account.inFiat} ${(fiatState is FiatLoaded) ? fiatState.fiat.name : "lolading..."}',
                              style: Theme.of(context).textTheme.button,
                            );
                          }),
                          SizedBox(height: 24),
                        ]),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(
                                    color: Theme.of(context).dividerColor))),
                        child: Row(
                          children: [
                            Expanded(
                                child: TertiaryButton(
                              t('send'),
                              () {
                                Navigator.of(context).pushNamed(
                                    TransactionScreen.routeName,
                                    arguments: {"account": state.account});
                              },
                              textColor: MyColors.primary_04,
                              iconImg: AssetImage(
                                  'assets/images/icons/ic_send_black.png'),
                            )),
                            Expanded(
                                child: TertiaryButton(
                              t('receive'),
                              () {
                                Navigator.of(context).pushNamed(
                                    ReceiveScreen.routeName,
                                    arguments: {"account": state.account});
                              },
                              textColor: MyColors.primary_03,
                              iconImg: AssetImage(
                                  'assets/images/icons/ic_receive_black.png'),
                            )),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: ListView.builder(
                              itemCount: state.transactions.length,
                              itemBuilder: (context, index) {
                                Transaction transaction =
                                    state.transactions[index];
                                Account account = state.account;
                                return TransactionItem(
                                    account: account, transaction: transaction);
                              },
                            ),
                          ),
                        ),
                      )
                    ]),
                  )
                : SizedBox();
          }),
    );
  }
}
