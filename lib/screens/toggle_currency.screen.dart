import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidewallet3/blocs/toggle_token/toggle_token_bloc.dart';
import 'package:tidewallet3/helpers/logger.dart';

import '../widgets/appBar.dart';

class ToggleCurrencyScreen extends StatefulWidget {
  @override
  _ToggleCurrencyScreenState createState() => _ToggleCurrencyScreenState();
  static const routeName = '/toggle-currency';
}

class _ToggleCurrencyScreenState extends State<ToggleCurrencyScreen> {
  ToggleTokenBloc _bloc;

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<ToggleTokenBloc>(context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: GeneralAppbar(
          routeName: ToggleCurrencyScreen.routeName,
          title: '添加貨幣',
        ),
        body: BlocBuilder<ToggleTokenBloc, ToggleTokenState>(
          bloc: _bloc,
          builder: (BuildContext context, ToggleTokenState state) {
            if (state is ToggleTokenLoaded) {
              state.list.forEach((element) {
                          Log.info(element);

              });

              return Container(
                child: Column(
                  children: state.list.map((l) => Text(l.symbol)).toList(),
                ),
              );
            } else {
              return Container();
            }
          },
        ));
  }
}
