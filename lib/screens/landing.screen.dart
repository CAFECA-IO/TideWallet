import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alice/alice.dart';
import 'package:local_auth/auth_strings.dart';
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
import '../helpers/logger.dart';

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
  Alice alice;

// -- TEST AUTH
  final noEnrolledWording = "未啟用生物辨識";

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final LocalAuthentication _localAuth = LocalAuthentication();
  String _canEvaluatePolicy = "";
  String _biometryType = "";

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    canCheckBiometrics = await _localAuth.canCheckBiometrics;

    if (!mounted) return;

    setState(() {
      _canEvaluatePolicy = canCheckBiometrics ? "是" : "否";
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics =
        await _localAuth.getAvailableBiometrics();

    if (!mounted) return;

    if (availableBiometrics.isEmpty) {
      _biometryType = noEnrolledWording;
    } else {
      if (availableBiometrics.contains(BiometricType.face)) {
        _biometryType = "點我驗證Face ID";
        Log.debug(_biometryType);
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        _biometryType = "點我驗證Touch ID";
        Log.debug('_biometryType');
      }
      // if (Platform.isIOS) {
      //   if (availableBiometrics.contains(BiometricType.face)) {
      //     Log.debug('IOS Face ID');
      //   } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      //     Log.debug('IOS Touch ID');
      //   }
      // } else {
      //   if (availableBiometrics.contains(BiometricType.fingerprint)) {
      //     Log.debug('Android Touch ID');
      //   } else if (availableBiometrics.contains(BiometricType.face)) {
      //     Log.debug('Android Face ID');
      //   }
      // }
    }
  }

  Future<void> _authenticate() async {
    print("驗證中");
    bool authenticated = false;

    // try {
    authenticated = await _localAuth.authenticateWithBiometrics(
        localizedReason: _biometryType,
        stickyAuth: true,
        useErrorDialogs: true,
        iOSAuthStrings: IOSAuthMessages(
            lockOut: "鎖",
            goToSettingsButton: "設定",
            goToSettingsDescription: "請設定",
            cancelButton: "算了"),
        androidAuthStrings: AndroidAuthMessages(
            biometricHint: "鎖",
            goToSettingsButton: "設定",
            goToSettingsDescription: "請設定",
            cancelButton: "Cancel"));
    // } on PlatformException catch (e) {
    //   print("例外");
    //   print(e);
    // }

    if (!mounted) return;

    final result = authenticated ? "驗證成功" : "驗證失敗";
    // scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(result)));
  }
// --

  @override
  void initState() {
    super.initState();

    if (Config.alice) {
      alice = Alice(
          showNotification: true, navigatorKey: navigatorKey, darkTheme: true);
      HTTPAgent().setAlice(alice);
    }
    // -- TEST AUTH
    _checkBiometrics();
    _getAvailableBiometrics();
    // --
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
            _authenticate();
            return HomeScreen();
          }

          return WelcomeScreen();
        },
      ),
    );
  }
}
