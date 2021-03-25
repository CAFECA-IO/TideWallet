import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home.screen.dart';
import '../blocs/local_auth/local_auth_bloc.dart';
import '../widgets/buttons/primary_button.dart';
import '../helpers/i18n.dart';
import '../helpers/logger.dart';

class AuthenticateScreen extends StatefulWidget {
  static const routeName = '/authenticate';

  @override
  _AuthenticateScreenState createState() => _AuthenticateScreenState();
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  bool isAuthenticated = false;
  final t = I18n.t;
  LocalAuthBloc _bloc;
  Widget _child;

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<LocalAuthBloc>(context);
    _child = Scaffold(
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
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalAuthBloc, LocalAuthState>(
      builder: (context, state) {
        Log.debug('state: $state');

        if (state is AuthenticationStatus)
          return state.isAuthenicated
              ? HomeScreen()
              : Scaffold(
                  body: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/welcome_bg.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(52.0, 100.0, 52.0, 40.0),
                    height: double.infinity,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo_type.png',
                          width: 107.0,
                        ),
                        Spacer(),
                        PrimaryButton(
                          t('authenticate'),
                          () {
                            this._bloc.add(Authenticate());
                          },
                          iconImg: AssetImage(
                              'assets/images/icons/ic_property_normal.png'),
                        ),
                      ],
                    ),
                  ),
                );
        else
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
      },
    );
  }
}
