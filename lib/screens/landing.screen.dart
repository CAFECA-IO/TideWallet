import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import './welcome.screen.dart';
import './home.screen.dart';
import '../repositories/user_repository.dart';
import '../blocs/fiat/fiat_bloc.dart';
import '../blocs/user/user_bloc.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isInit = true;
  UserBloc _bloc;
  FiatBloc _fiatBloc;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _bloc = BlocProvider.of<UserBloc>(context)..add(UserCheck());
      _fiatBloc = BlocProvider.of<FiatBloc>(context);
      _isInit = false;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    _fiatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserSuccess) {
          return HomeScreen();
        }

        return WelcomeScreen();
      },
    );
  }
}
