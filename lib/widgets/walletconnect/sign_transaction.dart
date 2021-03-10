import 'package:flutter/material.dart';

import '../../helpers/formatter.dart';
import '../../widgets/buttons/primary_button.dart';

class SignTransaction extends StatelessWidget {
  final BuildContext _context;
  final String _dapp;
  final Map _param;
  SignTransaction(this._context, this._dapp, this._param);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      padding: EdgeInsets.only(
        top: MediaQuery.of(_context).padding.top,
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0))),
            child: Row(
              children: [
                InkWell(
                  child: Text('取消',
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          .copyWith(fontSize: 18.0)),
                  onTap: () {},
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icons/ic_send_black.png',
                  width: 40.0,
                  color: Theme.of(context).textTheme.caption.color,
                ),
                SizedBox(
                  width: 4.0,
                ),
                Text(
                  '- ${_param['value']} ETH',
                  style: Theme.of(context).textTheme.headline1,
                ),
                Text('(\$)')
              ],
            ),
          ),
          TxItem('從',
              '主錢包(${Formatter.formatAdddress(_param['from'], showLength: 14)})'),
          TxItem('DAPP', _dapp),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: Row(
              children: [
                Text(
                  '網路費用',
                  style: Theme.of(context)
                      .textTheme
                      .headline1
                      .copyWith(fontSize: 16),
                ),
                Spacer(),
                Text(' ${_param['gasPrice']} ${_param['gas']} ETH'),
                Text('(\$)')
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            padding: const EdgeInsets.all(12.0),
            color: Theme.of(context).dividerColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最大總計',
                  style: Theme.of(context)
                      .textTheme
                      .headline1
                      .copyWith(fontSize: 18),
                ),
                Text(
                    '\$ ${_param['value']} ${_param['gasPrice']} ${_param['gas']}')
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Color(0xFFECF5FF),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 13.0),
              child: Text(
                '請確保您信任此應用程式。我們不用對此應用程式內的任何操作負責。',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 50.0),
            child: PrimaryButton('發送', () {}),
          )
        ],
      ),
    );
  }
}

class TxItem extends StatelessWidget {
  final String _title;
  final String _value;

  TxItem(this._title, this._value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_title,
              style:
                  Theme.of(context).textTheme.headline1.copyWith(fontSize: 16)),
          SizedBox(
            height: 6.0,
          ),
          Text(
            _value,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
