import 'package:flutter/material.dart';

import 'buttons/primary_button.dart';

class SwapSuccess extends StatelessWidget {
  final Map<String, String> from;
  final Map<String, String> to;
  final Function onPressed;

  SwapSuccess(this.from, this.to, this.onPressed);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).backgroundColor.withOpacity(0.8),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Success!',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                  Text(
                    'You have exchanged.',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(height: 40.0),
                  Stack(
                    children: <Widget>[
                      Column(
                        children: [
                          SwapItem(from['icon'], from['amount']),
                          SizedBox(height: 8.0),
                          SwapItem(to['icon'], to['amount']),
                        ],
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 0,
                                    spreadRadius: 4,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3),
                                  )
                                ]),
                            child: Icon(
                              Icons.arrow_downward,
                              color: Color(0xFFEEEEEE),
                              size: 14.0,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: PrimaryButton('Ok', () {
              onPressed();
              Navigator.of(context).popUntil(
                (ModalRoute.withName('/')),
              ); // To MaterialApp root
            }),
          )
        ],
      ),
    );
  }
}

class SwapItem extends StatelessWidget {
  final String icon;
  final String amount;

  SwapItem(this.icon, this.amount);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0, bottom: 24.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Theme.of(context).backgroundColor.withOpacity(0.9)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            icon,
            width: 28.0,
            height: 28.0,
          ),
          SizedBox(width: 10.0),
          Text(amount)
        ],
      ),
    );
  }
}
