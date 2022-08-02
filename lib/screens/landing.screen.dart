import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alice/alice.dart';
import 'package:local_auth/local_auth.dart';
import '../constants/log_config.dart';

import '../database/db_operator.dart';
import './welcome.screen.dart';
import './home.screen.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../blocs/account_currency/account_currency_bloc.dart';
import '../blocs/fiat/fiat_bloc.dart';
import '../blocs/user/user_bloc.dart';
import '../main.dart';
import '../helpers/http_agent.dart';

class LandingScreen extends StatefulWidget {
  static const routeName = 'landing-screen';
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _isInit = true;
  UserBloc _bloc;
  FiatBloc _fiatBloc;
  AccountCurrencyBloc _accountBloc;
  Alice alice;

  @override
  void initState() {
    super.initState();

    if (Config.alice) {
      alice = Alice(
          showNotification: true, navigatorKey: navigatorKey, darkTheme: true);
      HTTPAgent().setAlice(alice);
    }
  }

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
            _authenticateUser().then(
                (isAuthenticated) => isAuthenticated ? HomeScreen() : null);
          }

          return WelcomeScreen();
        },
      ),
    );
  }

  // To check if any type of biometric authentication
  // hardware is available.
  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;
    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return isAvailable;

    isAvailable
        ? print('Biometric is available!')
        : print('Biometric is unavailable.');

    return isAvailable;
  }

  // To retrieve the list of biometric types
  // (if available).
  Future<void> _getListOfBiometricTypes() async {
    List<BiometricType> listOfBiometrics;
    try {
      listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    print(listOfBiometrics);
  }

  // Process of authentication user using
  // biometrics.
  Future<bool> _authenticateUser() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticate(
        localizedReason:
            "Please authenticate to view your transaction overview",
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
      return false;
    }

    if (!mounted) return false;

    return isAuthenticated;
  }
}
