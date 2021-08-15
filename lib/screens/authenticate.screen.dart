import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/local_auth/local_auth_bloc.dart';
import '../blocs/user/user_bloc.dart';

import '../widgets/buttons/primary_button.dart';
import '../widgets/version.dart';
import '../helpers/i18n.dart';

class AuthenticateScreen extends StatefulWidget {
  static const routeName = '/authenticate';

  @override
  _AuthenticateScreenState createState() => _AuthenticateScreenState();
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  bool isAuthenticated = false;
  final t = I18n.t;
  late LocalAuthBloc _bloc;
  late UserBloc _userbloc;

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<LocalAuthBloc>(context);
    _userbloc = BlocProvider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    _userbloc.close();
    super.dispose();
  }

  Widget _unAuthLayout({List<Widget>? widgets}) {
    List<Widget> column = [
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
      Spacer(),
    ];

    if (widgets != null) {
      column += widgets;
    }
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
        padding: EdgeInsets.fromLTRB(52.0, 100.0, 52.0, 40.0),
        child: Column(children: column),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocalAuthBloc, LocalAuthState>(
      listener: (context, state) {
        if (state is AuthenticationStatus && state.isAuthenicated) {
          this._userbloc.add(UserInit());
        }
      },
      child: _unAuthLayout(
        widgets: [
          PrimaryButton(
            t('authenticate'),
            () {
              this._bloc.add(Authenticate());
            },
            iconImg: AssetImage('assets/images/icons/ic_property_normal.png'),
          ),
        ],
      ),
    );
  }
}
