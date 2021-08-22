import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidewallet3/helpers/logger.dart';
import 'package:tidewallet3/widgets/version.dart';

import '../database/db_operator.dart';
import '../blocs/user/user_bloc.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/loading_dialog.dart';

import 'authenticate.screen.dart';
import 'welcome.screen.dart';
import 'home.screen.dart';
// import '../services/fcm_service.dart';

class LandingScreen extends StatefulWidget {
  static const routeName = 'landing-screen';
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  // FCM _fcm = FCM();
  bool _isInit = true;
  bool _debugMode = false;
  late UserBloc _bloc;

  @override
  void initState() {
    // _fcm.configure(navigatorKey);
    // _fcm.getToken().then((value) {
    //   print(value);
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    dynamic arg = ModalRoute.of(context)!.settings.arguments;
    if (arg != null) {
      this._debugMode = arg["debugMode"];
    }

    if (_isInit) {
      await DBOperator().init();
      _isInit = false;
    }
    _bloc = BlocProvider.of<UserBloc>(context)
      ..add(UserCheck(debugMode: this._debugMode));
    Log.debug('LandingScreen _isInit: ${this._isInit}');

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoading) {
          DialogController.showUnDissmissible(context, LoadingDialog());
        }
        if (state is UserExist || state is UserFail) {
          DialogController.dismiss(context);
        }

        if (state is UserAuthenticated) {
          Navigator.of(context).pushNamed(HomeScreen.routeName);
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
          if (state is UserLoading) {
            return Scaffold(
              body: Container(
                height: double.infinity,
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(52.0, 100.0, 52.0, 60.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/welcome_bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(children: [
                  Image.asset(
                    'assets/images/logo_type.png',
                    width: 107.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: Version(
                      fontSize: 18.0,
                      color: Colors.white70,
                    ),
                  ),
                ]),
              ),
            );
          }
          if (state is UserExist && state.existed) {
            return AuthenticateScreen();
          }
          // if (state is UserAuthenticated) {
          //   return HomeScreen();
          // }
          return WelcomeScreen();
        },
      ),
    );
  }
}
