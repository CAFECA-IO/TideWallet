import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/appBar.dart';
import '../blocs/fiat/fiat_bloc.dart';
import '../models/account.model.dart';
import '../helpers/i18n.dart';

class SettingFiatScreen extends StatefulWidget {
  static const routeName = 'setting-fiat';

  @override
  _SettingFiatScreenState createState() => _SettingFiatScreenState();
}

class _SettingFiatScreenState extends State<SettingFiatScreen> {
  final t = I18n.t;

  FiatBloc _bloc;

  Widget _fiatField(Fiat _fiat, {bool selected = false}) {
    return InkWell(
      onTap: _fiat != null
          ? () {
              _bloc.add(SwitchFiat(_fiat));
              Navigator.of(context).pop();
            }
          : null,
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(0, 10.0, 16.0, 10.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _fiat != null ? _fiat.name : '',
                style: TextStyle(
                  color: selected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyText1.color,
                ),
              ),
              selected
                  ? ImageIcon(
                      AssetImage('assets/images/icons/ic_confirm_normal.png'),
                      color: Theme.of(context).primaryColor,
                      size: 16.0,
                    )
                  : SizedBox()
            ],
          )),
    );
  }

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<FiatBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(
        title: t('fiat'),
        routeName: SettingFiatScreen.routeName,
      ),
      body: BlocBuilder<FiatBloc, FiatState>(
        builder: (context, state) {
          final int len = 20;

          if (state is FiatLoaded) {
            final l = List<Fiat>(len - state.list.length);
            List<Fiat> ls = state.list + l;

            return Container(
              padding: const EdgeInsets.only(left: 20.0),
              child: ListView.builder(
                itemCount: ls.length,
                itemBuilder: (BuildContext ctx, int index) {
                  bool _selected =
                      ls[index] != null && ls[index].name == state.fiat.name;
                  return _fiatField(ls[index], selected: _selected);
                },
              ),
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}
