import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../screens/setting_fiat.screen.dart';
import '../../blocs/fiat/fiat_bloc.dart';
import '../../helpers/i18n.dart';

class FiatSetting extends StatefulWidget {
  final Widget _item;

  FiatSetting(this._item);
  @override
  _FiatSettingState createState() => _FiatSettingState();
}

class _FiatSettingState extends State<FiatSetting> {
  final t = I18n.t;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiatBloc, FiatState>(
      builder: (context, state) {
        if (state is FiatLoaded) {
          Color _color = Theme.of(context).primaryColor;
          return InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(SettingFiatScreen.routeName);
            },
            child: Container(
              padding: const EdgeInsets.only(
                right: 20.0,
                left: 4.0,
                top: 10.0,
                bottom: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t('setting_fiat'),),
                  Row(
                    children: [
                      Text(state.fiat.name, style: TextStyle(color: _color),),
                      SizedBox(width: 10.0),
                      ImageIcon(
                        AssetImage('assets/images/icons/ic_arrow_right_normal.png'),
                        color: _color,
                        size: 16.0,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }

        return widget._item;
      },
    );
  }
}
