import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidewallet3/theme.dart';

import '../models/account.model.dart';
import '../blocs/toggle_token/toggle_token_bloc.dart';
import '../widgets/appBar.dart';
import '../helpers/i18n.dart';

class ToggleCurrencyScreen extends StatefulWidget {
  @override
  _ToggleCurrencyScreenState createState() => _ToggleCurrencyScreenState();
  static const routeName = '/toggle-currency';
}

class _ToggleCurrencyScreenState extends State<ToggleCurrencyScreen> {
  late ToggleTokenBloc _bloc;
  final t = I18n.t;

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<ToggleTokenBloc>(context);
    _bloc.add(InitTokens());
    super.didChangeDependencies();
  }

  _toggle(DisplayCurrency dc, bool value) {
    _bloc.add(ToggleToken(dc, value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: GeneralAppbar(
          routeName: ToggleCurrencyScreen.routeName,
          title: t('add_currency'),
        ),
        body: BlocBuilder<ToggleTokenBloc, ToggleTokenState>(
          bloc: _bloc,
          builder: (BuildContext context, ToggleTokenState state) {
            if (state is ToggleTokenLoaded) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: state.list
                        .map((l) => ToggleItem(l, this._toggle))
                        .toList(),
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        ));
  }
}

class ToggleItem extends StatelessWidget {
  final DisplayCurrency _dc;
  final Function _toggle;

  ToggleItem(this._dc, this._toggle);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: MyColors.secondary_02, width: 0.5))),
      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, right: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.network(
              _dc.icon,
              width: 20.0,
              height: 20.0,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_dc.symbol, style: TextStyle(fontSize: 16.0)),
              Text(
                _dc.name,
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .copyWith(fontSize: 12.0),
              ),
            ],
          ),
          Spacer(),
          CupertinoSwitch(
            value: _dc.opened,
            onChanged: (bool value) {
              this._toggle(_dc, value);
            },
          ),
        ],
      ),
    );
  }
}
