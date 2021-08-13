import 'package:flutter/material.dart';

import '../models/account.model.dart';
import '../helpers/formatter.dart';
import './inputs/normal_input.dart';
import '../theme.dart';

class SwapCard extends StatelessWidget {
  final Account _account;
  final Function(String)? onChanged;
  final TextEditingController amountController;
  final FocusNode focusNode;
  final bool readOnly;
  final List<Account>? currencies;
  final Function? onSelect;
  final String label;
  final Function()? onTap;

  SwapCard(
    this._account, {
    required this.label,
    this.currencies,
    required this.onChanged,
    required this.amountController,
    required this.focusNode,
    this.onSelect,
    this.readOnly: true,
    this.onTap,
  });

  _openList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: bottomSheetShape,
      builder: (ctx) {
        return Container(
          child: ListView(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 20.0),
                child: InkWell(
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).dividerColor,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).primaryColor.withAlpha(10),
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: [
                          BoxShadow(
                              color: Theme.of(context).dividerColor,
                              blurRadius: 2,
                              spreadRadius: 0.5,
                              offset: Offset(0, 1))
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: currencies == null
                          ? []
                          : currencies!
                              .map(
                                (e) => InkWell(
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 20.0),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Image.network(e.imgPath!,
                                                width: 30.0, height: 30.0),
                                            SizedBox(width: 10.0),
                                            Text(
                                              e.name!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2,
                                            ),
                                            Spacer(),
                                            Text(
                                                '${Formatter.formatDecimal(e.balance)} ${e.symbol!.toUpperCase()}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption)
                                          ])),
                                  onTap: () {
                                    onSelect!(e);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  _openList(context);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      _account.imgPath!,
                      width: 36.0,
                      height: 36.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _account.symbol!.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .headline1!
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                    Container(
                      child: Icon(Icons.arrow_drop_down),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Balance: ${Formatter.formatDecimal(_account.balance)} ${_account.symbol}',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
              Container(
                width: 100,
                height: 40,
                // color: Colors.blueGrey,
                child: NormalInput(
                  onTap: onTap,
                  focusNode: focusNode,
                  readOnly: readOnly,
                  fontSize: Theme.of(context).textTheme.headline3!.fontSize!,
                  controller: amountController,
                  onChange: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Deprecated
class OutputRateBtn extends StatelessWidget {
  final String _text;
  final Function()? _onPressed;

  OutputRateBtn(this._text, this._onPressed);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.0,
      height: 20.0,
      child: FlatButton(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
              side: BorderSide(color: Theme.of(context).primaryColor)),
          color: Colors.transparent,
          child: Text(
            _text,
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(color: Theme.of(context).primaryColor),
          ),
          onPressed: _onPressed),
    );
  }
}
