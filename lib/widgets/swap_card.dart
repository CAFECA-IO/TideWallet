import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../models/account.model.dart';
import '../helpers/formatter.dart';
import './inputs/normal_input.dart';
import '../theme.dart';

class SwapCard extends StatelessWidget {
  final Currency _currency;
  final Function onPercentChanged;
  final int percent;
  final bool isSender;
  final Function onChanged;
  final TextEditingController amountController;
  final List<Currency> currencies;
  final Function onSelect;

  SwapCard(this._currency,
      {this.percent,
      this.onPercentChanged,
      this.isSender: true,
      this.currencies,
      this.onChanged,
      this.amountController,
      this.onSelect})
      : assert(
          (isSender && percent != null && onPercentChanged != null) ||
              (!isSender &&
                  onChanged != null &&
                  amountController != null &&
                  percent != null &&
                  onPercentChanged != null),
        );

  _openList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: bottomSheetShape,
      builder: (ctx) {
        return Container(
          child: Column(
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
                      children: currencies
                          .map(
                            (e) => InkWell(
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 20.0),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.network(e.imgPath,
                                            width: 30.0, height: 30.0),
                                        SizedBox(width: 10.0),
                                        Text(
                                          e.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                        Spacer(),
                                        Text(
                                            '${Formatter.formatDecimal(e.amount)} ${e.symbol.toUpperCase()}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption)
                                      ])),
                              onTap: () {
                                onSelect(e);
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
    if (!isSender) print(percent);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                _currency.imgPath,
                width: 36.0,
                height: 36.0,
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        _currency.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Balance: ${_currency.amount} ${_currency.symbol}',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    if (isSender)
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Theme.of(context).primaryColor,
                          inactiveTrackColor: Color(0xFFDDDDDD),
                          trackHeight: 3.0,
                          thumbColor: Theme.of(context).primaryColorLight,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 6.0),
                          overlayColor: Colors.purple.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 10.0),
                        ),
                        child: Slider(
                          label: percent.round().toString() + '%',
                          value: percent.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 100,
                          onChanged: (double v) {
                            onPercentChanged(v.toInt());
                          },
                        ),
                      ),
                  ],
                ),
              ),
              InkWell(
                child: Icon(Icons.arrow_drop_down),
                onTap: () {
                  _openList(context);
                },
              ),
            ],
          ),
          if (isSender) SizedBox(height: 20.0),
          if (isSender)
            Container(
              width: double.infinity,
              child: Text(
                (Decimal.tryParse(_currency.amount) *
                        Decimal.fromInt(percent) /
                        Decimal.fromInt(100))
                    .toString(),
                style: Theme.of(context).textTheme.headline3.copyWith(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          if (!isSender)
            NormalInput(
              fontSize: Theme.of(context).textTheme.headline3.fontSize,
              controller: amountController,
              onChange: onChanged,
            )
        ],
      ),
    );
  }
}

// Deprecated
class OutputRateBtn extends StatelessWidget {
  final String _text;
  final Function _onPressed;

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
                .subtitle2
                .copyWith(color: Theme.of(context).primaryColor),
          ),
          onPressed: _onPressed),
    );
  }
}
