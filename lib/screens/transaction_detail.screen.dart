import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../blocs/transaction_status/transaction_status_bloc.dart';
import '../theme.dart';
import '../helpers/logger.dart';
import '../helpers/i18n.dart';
import '../helpers/formatter.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../widgets/appBar.dart';
import '../widgets/dash_line_divider.dart';
import '../widgets/copy_tool_tip.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/trader_repository.dart';

class TransactionDetailScreen extends StatefulWidget {
  // final Currency currency;
  // final Transaction transaction;

  static const routeName = '/transaction-detail';

  const TransactionDetailScreen({Key key}) : super(key: key);

  @override
  _TransactionDetailScreenState createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final t = I18n.t;
  TransactionStatusBloc _bloc;
  TransactionRepository _repo;
  TraderRepository _traderRepo;
  Currency _currency;
  Transaction _transaction;

  @override
  void didChangeDependencies() {
    Map<String, dynamic> arg = ModalRoute.of(context).settings.arguments;
    _currency = arg["currency"];
    _transaction = arg["transaction"];
    _repo = Provider.of<TransactionRepository>(context);

    _traderRepo = Provider.of<TraderRepository>(context);
    Log.debug(_transaction.status);
    Log.debug(_transaction.amount);
    Log.debug(_transaction.confirmations);
    Log.debug(_transaction.direction);

    _bloc = TransactionStatusBloc(_repo, _traderRepo)
      ..add(UpdateTransaction(_transaction)); // TODO GetTransactionList
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Log.debug("build");
    return Scaffold(
      appBar: GeneralAppbar(
        title: t('transaction_detail'),
        routeName: TransactionDetailScreen.routeName,
      ),
      body: BlocBuilder<TransactionStatusBloc, TransactionStatusState>(
          bloc: _bloc,
          builder: (context, state) {
            _transaction = state.transaction ?? _transaction;
            return Container(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              margin: EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_transaction.direction == TransactionDirection.sent ? "-" : "+"} ${Formatter.formatDecimal(_transaction.amount.toString(), decimalLength: 12)}',
                        style: Theme.of(context).textTheme.headline1.copyWith(
                            color:
                                _transaction.status != TransactionStatus.success
                                    ? MyColors.secondary_03
                                    : _transaction.direction.color,
                            fontSize: 32),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        _currency.symbol,
                        style: Theme.of(context).textTheme.headline1.copyWith(
                              color: _transaction.status !=
                                      TransactionStatus.success
                                  ? MyColors.secondary_03
                                  : _transaction.direction.color,
                            ),
                      )
                    ],
                  ),
                  SizedBox(height: 24),
                  DashLineDivider(
                    color: Theme.of(context).dividerColor,
                  ),
                  SizedBox(height: 16),
                  Align(
                    child: Text(
                      t('status'),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Align(
                      child: Row(
                        children: [
                          Text(
                            '${t(_transaction.status.title)} (${_transaction.confirmations} ${t('confirmation')})',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: _transaction.status.color),
                          ),
                          SizedBox(width: 8),
                          ImageIcon(
                            AssetImage(_transaction.status.iconPath),
                            size: 20.0,
                            color: _transaction.status.color,
                          ),
                        ],
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  SizedBox(height: 24),
                  Align(
                    child: Text(
                      t('time'),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      child: Text(
                        '(${Formatter.dateTime(_transaction.dateTime)})',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  SizedBox(height: 24),
                  Align(
                    child: Text(
                      t(_transaction.direction.subtitle),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  CopyToolTip(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Align(
                        child: Text(
                          _transaction.address,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    text: _transaction.address,
                  ),
                  SizedBox(height: 24),
                  Align(
                    child: Text(
                      t('transaction_fee'),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      child: Text(
                        '${Formatter.formatDecimal(_transaction.fee.toString())} ${_currency.accountSymbol}',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  SizedBox(height: 24),
                  Align(
                    child: Text(
                      t('transaction_id'),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          child: Image.network(_currency.imgPath),
                          width: 24,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: () => _launchURL(
                              'https://blockexplorer.one/${_currency.symbol.toLowerCase()}/${_currency.network.toLowerCase()}/tx/${_transaction.txId}'),
                          child: Text(
                            Formatter.formatAdddress(_transaction.txId),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    color: Theme.of(context).primaryColor,
                                    decoration: TextDecoration.underline),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
