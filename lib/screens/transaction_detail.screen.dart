import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../blocs/transaction_detail/transaction_detail_bloc.dart';
import '../repositories/transaction_repository.dart';
import '../theme.dart';
import '../helpers/logger.dart';
import '../helpers/i18n.dart';
import '../helpers/formatter.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../widgets/appBar.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../widgets/dash_line_divider.dart';
import '../widgets/copy_tool_tip.dart';

import '../constants/account_config.dart';

class TransactionDetailScreen extends StatefulWidget {
  static const routeName = '/transaction-detail';

  const TransactionDetailScreen({Key? key}) : super(key: key);

  @override
  _TransactionDetailScreenState createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final t = I18n.t;
  late TransactionDetailBloc _bloc;

  @override
  void didChangeDependencies() {
    Map<String, dynamic> arg =
        ModalRoute.of(context)!.settings.arguments! as Map<String, dynamic>;
    String _accountId = arg["accountId"];
    String txid = arg["txid"];

    _bloc = TransactionDetailBloc(Provider.of<TransactionRepository>(context))
      ..add(GetTransactionDetial(_accountId, txid)); // TODO GetTransactionList
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  String getLaunchLink(Account account, transaction) {
    const PROTOCAL = 'https://';
    String network = account.network.toLowerCase();

    switch (account.accountType) {
      case ACCOUNT.BTC:
        if (network == 'bitcoin') {
          network = 'mainnet';
        }

        if (network == 'bitcoin testnet') {
          network = 'testnet';
        }

        return '$PROTOCAL${Explorer.BLOCK_EXPLORER}/${account.symbol.toLowerCase()}/$network/tx/${transaction.txId}';
      case ACCOUNT.ETH:
        return '$PROTOCAL${network == 'ethereum' ? '' : network + '.'}${Explorer.ETHERSCAN}/tx/${transaction.txId}';
      case ACCOUNT.CFC:
        return '$PROTOCAL${Explorer.TITAN_EXPLORER}/tx/${transaction.txId}';

      default:
        throw Error(); // -- debugInfo, null-safety
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(
        title: t('transaction_detail'),
        routeName: TransactionDetailScreen.routeName,
      ),
      body: BlocBuilder<TransactionDetailBloc, TransactionDetailState>(
          bloc: _bloc,
          builder: (context, state) {
            if (state is TransactionDetailLoaded) {
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
                          '${state.transaction.direction == TransactionDirection.sent ? "-" : "+"} ${Formatter.formatDecimal(state.transaction.amount.toString(), decimalLength: 12)}',
                          style: Theme.of(context)
                              .textTheme
                              .headline1!
                              .copyWith(
                                  color: state.transaction.status !=
                                          TransactionStatus.success
                                      ? MyColors.secondary_03
                                      : state.transaction.direction.color,
                                  fontSize: 32),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          state.account.symbol,
                          style:
                              Theme.of(context).textTheme.headline1!.copyWith(
                                    color: state.transaction.status !=
                                            TransactionStatus.success
                                        ? MyColors.secondary_03
                                        : state.transaction.direction.color,
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
                              '${t(state.transaction.status!.title)} (${state.transaction.confirmations} ${t('confirmation')})',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                      color: state.transaction.status!.color),
                            ),
                            SizedBox(width: 8),
                            ImageIcon(
                              AssetImage(state.transaction.status!.iconPath),
                              size: 20.0,
                              color: state.transaction.status!.color,
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
                          '(${Formatter.dateTime(state.transaction.dateTime!)})',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    SizedBox(height: 24),
                    Align(
                      child: Text(
                        t(state.transaction.direction.subtitle),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    CopyToolTip(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Align(
                          child: Text(
                            state.transaction.address,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      text: state.transaction.address,
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
                          '${Formatter.formatDecimal(state.transaction.fee.toString())} ${state.shareAccount.symbol}',
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
                            child: Image.network(state.account.imgPath),
                            width: 24,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          GestureDetector(
                            onTap: () {
                              try {
                                String url = this.getLaunchLink(
                                    state.account, state.transaction);
                                _launchURL(url);
                              } catch (error) {
                                Log.debug(error); // ++ errorhandle, null-safety
                              }
                            },
                            child: Text(
                              Formatter.formatAdddress(state.transaction.txId!),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
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
            } else {
              return Center(
                child: LoadingDialog(),
              );
            }
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
