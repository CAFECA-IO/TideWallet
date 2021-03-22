import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../cores/account.dart';
import '../models/account.model.dart';
import '../blocs/swap/swap_bloc.dart';
import '../repositories/swap_repository.dart';
import '../repositories/transaction_repository.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/swap_card.dart';
import '../widgets/swap_confirm.dart';
import '../widgets/swap_success.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/computer_keyborad.dart';

import '../helpers/i18n.dart';
import '../helpers/formatter.dart';
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
  TransactionRepository _traderRepo;
  SwapBloc _swapBloc;
  TextEditingController _sellAmountController = TextEditingController();
  TextEditingController _buyAmountController = TextEditingController();
  Map<String, String> _sellCurrency;
  Map<String, String> _buyCurrency;
  bool _isInit = true;
  FocusNode _sellAmountFocusNode = FocusNode();
  FocusNode _buyAmountFocusNode = FocusNode();
  TextEditingController _currentController;
  FocusNode _currentFocusNode;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _swapRepo = Provider.of<SwapRepository>(context);
      _traderRepo = Provider.of<TransactionRepository>(context);
      _swapBloc = SwapBloc(_swapRepo, _traderRepo);
      _currentController = _sellAmountController;
      _currentFocusNode = _sellAmountFocusNode;
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
    _sellAmountController.dispose();
    _buyAmountController.dispose();
    _sellAmountFocusNode.dispose();
    _buyAmountFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(_currentFocusNode);
    return BlocListener<SwapBloc, SwapState>(
      cubit: _swapBloc,
      listener: (ctx, state) {
        if (state is SwapLoaded) {
          // UpdateUsePercent || ChangeSwapTarget
          if (state.buyAmount.toString() != _buyAmountController.text)
            _buyAmountController.text = state.buyAmount.toString();

          if (state.sellAmount.toString() != _sellAmountController.text)
            _sellAmountController.text = state.sellAmount.toString();

          // SwapConfirmed
          if (state.result == SwapResult.success)
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) =>
                  SwapSuccess(_sellCurrency, _buyCurrency, () {
                this._swapBloc.add(InitSwap(state.sellCurrency));
              }),
            );

          if (state.result == SwapResult.failure) {
            // ++ add Key and data to translation file. Emily 2021/3/18
            DialogController.show(
                context, ErrorDialog(state.result.toString()));
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
                confirmFunc: (String password) {
                  _swapBloc.add(SwapConfirmed(password));
                },
              ),
            );
          }

          if (state.result == SwapResult.insufficient) {
            // ++ SHOW ERROR 2021/3/17 Emily
            Log.error(state.result.toString());
          }

          if (state.result == SwapResult.zero) {
            // ++ SHOW ERROR 2021/3/17 Emily
            Log.error(state.result.toString());
          }

          if (state.result == SwapResult.failure) {
            // ++ SHOW ERROR 2021/3/17 Emily
            Log.error(state.result.toString());
          }
          // <== CheckSwap

        }
      },
      child: BlocBuilder<SwapBloc, SwapState>(
        cubit: _swapBloc,
        builder: (context, state) {
          if (state is SwapLoaded) {
            return Column(
              children: <Widget>[
                Container(
                  height: 90,
                  color: Colors.white,
                ),
                Container(
                  child: Stack(
                    children: <Widget>[
                      Column(
                        children: [
                          SwapCard(state.sellCurrency,
                              onTap: () {
                                setState(() {
                                  _currentController = _sellAmountController;
                                  _currentFocusNode = _sellAmountFocusNode;
                                });
                              },
                              focusNode: _sellAmountFocusNode,
                              amountController: _sellAmountController,
                              label: t('send'),
                              onChanged: (String v) {
                                if (v.isEmpty) return;
                                _swapBloc.add(UpdateBuyAmount(v));
                              },
                              onSelect: (Currency v) {
                                _swapBloc.add(ChangeSwapSellCurrency(v));
                              },
                              currencies: [state.sellCurrency] + state.targets),
                          SwapCard(state.buyCurrency,
                              onTap: () {
                                setState(() {
                                  _currentController = _buyAmountController;
                                  _currentFocusNode = _buyAmountFocusNode;
                                });
                              },
                              focusNode: _buyAmountFocusNode,
                              amountController: _buyAmountController,
                              label: t('receive'),
                              onChanged: (String v) {
                                if (v.isEmpty) return;
                                _swapBloc.add(UpdateBuyAmount(v));
                              },
                              onSelect: (Currency v) {
                                _swapBloc.add(ChangeSwapBuyCurrency(v));
                              },
                              currencies: state.targets),
                        ],
                      ),
                      Positioned.fill(
                        // right: 40.0,
                        child: Align(
                            alignment: Alignment.center,
                            child: Divider(color: Colors.black26)),
                      ),
                      Positioned.fill(
                        // right: 40.0,
                        child: Align(
                          alignment: Alignment.center,
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
                SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t('exchange_rate'),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                          '1 ${state.sellCurrency.symbol} = ${Formatter.formatDecimal(state.exchangeRate)} ${state.buyCurrency.symbol}')
                      // Text('${state.sellCurrency.symbol}/${state.buyCurrency.symbol} = ${state.exchangeRate}')
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      PrimaryButton('Swap', () {
                        _swapBloc.add(CheckSwap());
                      }),
                    ],
                  ),
                ),
                _currentFocusNode == _sellAmountFocusNode
                    ? Container(
                        child: ComputerKeyboard(
                          _sellAmountController,
                          focusNode: _sellAmountFocusNode,
                        ),
                      )
                    : Container(
                        child: ComputerKeyboard(
                          _buyAmountController,
                          focusNode: _buyAmountFocusNode,
                        ),
                      ),
              ],
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}
