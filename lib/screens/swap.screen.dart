import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../cores/account.dart';
import '../models/account.model.dart';
import '../blocs/swap/swap_bloc.dart';
import '../repositories/swap_repository.dart';
import '../repositories/trader_repository.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/swap_card.dart';
import '../widgets/swap_confirm.dart';
import '../widgets/swap_success.dart';

import '../helpers/i18n.dart';
import '../helpers/logger.dart';
import '../theme.dart';

final t = I18n.t;

class SwapScreen extends StatefulWidget {
  static const routeName = '/swap';

  @override
  _SwapScreenState createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  SwapRepository _swapRepo;
  TraderRepository _traderRepo;
  SwapBloc _swapBloc;
  TextEditingController _amountController = TextEditingController();
  Map<String, String> _sellCurrency;
  Map<String, String> _buyCurrency;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _swapRepo = Provider.of<SwapRepository>(context);
      _traderRepo = Provider.of<TraderRepository>(context);
      _swapBloc = SwapBloc(_swapRepo, _traderRepo);

      Map argument = ModalRoute.of(context).settings.arguments;

      if (argument != null) {
        Currency currency = argument['currency'];
        _swapBloc.add(InitSwap(currency));
      } else {
        _swapBloc.add(InitSwap(AccountCore().getAllCurrencies()[0]));
      }
      _isInit = false;
    }

    super.didChangeDependencies();
  }

  @override
  dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SwapBloc, SwapState>(
      cubit: _swapBloc,
      listener: (ctx, state) {
        if (state is SwapLoaded) {
          // UpdateUsePercent || ChangeSwapTarget
          if (state.buyAmount.toString() != _amountController.text)
            _amountController.text = state.buyAmount.toString();

          // SwapConfirmed
          if (state.result == SwapResult.success)
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) => SwapSuccess(_sellCurrency, _buyCurrency),
            );

          if (state.result == SwapResult.failure) {
            // TODO: SHOW ERROR
            Log.error(state.result.toString());
          }

          // CheckSwap ==>
          if (state.result == SwapResult.valid) {
            _sellCurrency = {
              'icon': state.sellCurrency.imgPath,
              'symbol': state.sellCurrency.symbol,
              'amount': state.sellAmount.toString()
            };
            _buyCurrency = {
              'icon': state.buyCurrency.imgPath,
              'symbol': state.buyCurrency.symbol,
              'amount': state.buyAmount.toString()
            };
            showModalBottomSheet(
              isScrollControlled: true,
              shape: bottomSheetShape,
              context: context,
              builder: (context) => SwapConfirm(
                exchangeRate: state.exchangeRate.toString(),
                sellCurrency: _sellCurrency,
                buyCurrency: _buyCurrency,
                confirmFunc: () {
                  _swapBloc.add(SwapConfirmed());
                },
              ),
            );
          }

          if (state.result == SwapResult.insufficient) {
            // TODO: SHOW ERROR
            Log.error(state.result.toString());
          }

          if (state.result == SwapResult.zero) {
            // TODO: SHOW ERROR
            Log.error(state.result.toString());
          }

          if (state.result == SwapResult.failure) {
            // TODO: SHOW ERROR
            Log.error(state.result.toString());
          }
          // <== CheckSwap

        }
      },
      child: BlocBuilder<SwapBloc, SwapState>(
        cubit: _swapBloc,
        builder: (context, state) {
          if (state is SwapLoaded) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 20.0),
                    child: Text(
                      t('swap_info'),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exchange exchangeRate',
                          textAlign: TextAlign.center,
                        ),
                        Text(
                            '1 ${state.sellCurrency.symbol} = ${state.exchangeRate} ${state.buyCurrency.symbol}')
                        // Text('${state.sellCurrency.symbol}/${state.buyCurrency.symbol} = ${state.exchangeRate}')
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    // color: Theme.of(context).primaryColor,
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: [
                            SwapCard(state.sellCurrency,
                                percent: state.usePercent,
                                onPercentChanged: (int v) {
                              _swapBloc.add(UpdateUsePercent(v));
                            }, onSelect: (Currency v) {
                              _swapBloc.add(ChangeSwapSellCurrency(v));
                            },
                                currencies:
                                    [state.sellCurrency] + state.targets),
                            SizedBox(height: 10.0),
                            SwapCard(state.buyCurrency,
                                isSender: false,
                                percent: state.usePercent,
                                onChanged: (String v) {
                                  if (v.isEmpty) return;
                                  _swapBloc.add(UpdateBuyAmount(v));
                                },
                                amountController: _amountController,
                                onPercentChanged: (int v) {
                                  _swapBloc.add(UpdateUsePercent(v));
                                },
                                onSelect: (Currency v) {
                                  _swapBloc.add(ChangeSwapBuyCurrency(v));
                                },
                                currencies: state.targets),
                          ],
                        ),
                        Positioned.fill(
                          right: 40.0,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                  )
                                ],
                              ),
                              child: CircleAvatar(
                                child: Icon(Icons.cached,
                                    color: Theme.of(context).primaryColor),
                                backgroundColor: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            child: Text(
                              'Fee: ' +
                                  state.fee.toString() +
                                  state.sellCurrency.symbol,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        PrimaryButton('Swap', () {
                          _swapBloc.add(CheckSwap());
                        }),
                      ],
                    ),
                  )
                ],
              ),
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}
