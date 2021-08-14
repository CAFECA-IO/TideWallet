import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/db_operator.dart';
import '../blocs/user/user_bloc.dart';
import './welcome.screen.dart';
import './authenticate.screen.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../main.dart';
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
    Map<String, bool>? arg =
        ModalRoute.of(context)!.settings.arguments as Map<String, bool>?;
    if (arg != null && arg["debugMode"] != null) {
      this._debugMode = arg["debugMode"]!;
    }

    if (_isInit) {
      await DBOperator().init();
      _isInit = false;
    }
    _bloc = BlocProvider.of<UserBloc>(context)
      ..add(UserCheck(debugMode: this._debugMode));

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
          if (state is UserAuthenticated) {
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
          if (state is UserExist && state.existed) {
            return AuthenticateScreen();
          }
          return WelcomeScreen();
        },
      ),
    );
  }
}
