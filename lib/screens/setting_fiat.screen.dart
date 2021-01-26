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

  Widget _fiatField(Fiat _fiat) {
    return Container(
      child: Text(_fiat.name)
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
        title: '法幣',
        routeName: SettingFiatScreen.routeName,
      ),
      body: BlocBuilder<FiatBloc, FiatState>(
        builder: (context, state) {
          if (state is FiatLoaded) {
            return Container(
              padding: const EdgeInsets.only(left: 20.0),
              child: ListView.builder(
                itemCount: state.list.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return _fiatField(state.list[index]);
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
