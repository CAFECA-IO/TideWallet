import 'package:flutter/material.dart';

import './buttons/primary_button.dart';
import '../theme.dart';

class SwapConfirm extends StatelessWidget {
  final Map<String, String> sellCurrency;
  final Map<String, String> buyCurrency;
  final String exchangeRate;
  final Function confirmFunc;

  SwapConfirm(
      {this.sellCurrency,
      this.buyCurrency,
      this.confirmFunc,
      this.exchangeRate});

  @override
  Widget build(BuildContext context) {
    Widget accountItem(Map item) => Column(
          children: <Widget>[
            Image.asset(
              item['icon'],
              width: 30.0,
              height: 30.0,
            ),
            SizedBox(height: 10.0),
            Text(item['amount'])
          ],
        );

    Widget detailItem(String title, String value) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: MyColors.primary_06),
              ),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        );

    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 20.0),
                color: Theme.of(context).primaryColor.withAlpha(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        accountItem(sellCurrency),
                        Text(
                          'to',
                          style: TextStyle(color: MyColors.secondary_02),
                        ),
                        accountItem(buyCurrency)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Exchange Details',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xff000000).withOpacity(0.1),
                            blurRadius: 3,
                            spreadRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          detailItem('Amount',
                              '1${sellCurrency['symbol']} = $exchangeRate ${buyCurrency['symbol']}'),
                          detailItem('Exchanging To',
                              '${buyCurrency['amount']} ${buyCurrency['symbol']}'),
                          detailItem('Exchanging',
                              '${sellCurrency['amount']} ${sellCurrency['symbol']}')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              width: double.infinity,
              child: PrimaryButton('Confirm', confirmFunc),
            ),
          ],
        ),
      ),
    );
  }
}
