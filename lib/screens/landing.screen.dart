import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/db_operator.dart';
import './welcome.screen.dart';
import './home.screen.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../blocs/account_currency/account_currency_bloc.dart';
import '../blocs/fiat/fiat_bloc.dart';
import '../blocs/user/user_bloc.dart';

class LandingScreen extends StatefulWidget {
  static const routeName = 'landing-screen';
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isInit = true;
  UserBloc _bloc;
  FiatBloc _fiatBloc;
  AccountCurrencyBloc _accountBloc;

  @override
  void didChangeDependencies() async {
    Map<String, bool> arg = ModalRoute.of(context).settings.arguments;
    bool debugMode = arg != null ? arg["debugMode"] : false;
    if (_isInit || debugMode) {
      await DBOperator().init();
      // force AccountCurrencyBloc call constructor
      _accountBloc = BlocProvider.of<AccountCurrencyBloc>(context);
      _bloc = BlocProvider.of<UserBloc>(context)
        ..add(UserCheck(debugMode: debugMode));
      _fiatBloc = BlocProvider.of<FiatBloc>(context);
      _isInit = false;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    _fiatBloc.close();
    _accountBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoading) {
          DialogController.showUnDissmissible(context, LoadingDialog());
        }

        if (state is UserSuccess || state is UserFail) {
          DialogController.dismiss(context);
        }
      },
      listenWhen: (prevState, currState) {
        if (prevState is UserLoading || currState is UserLoading) {
          return true;
        } else {
          return false;
        }
      },
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserInitial) {
            return Scaffold(
              body: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/welcome_bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }
          if (state is UserSuccess) {
            return HomeScreen();
          }

          return WelcomeScreen();
        },
      ),
    );
  }
}
