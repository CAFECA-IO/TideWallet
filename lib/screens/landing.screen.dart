import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './welcome.screen.dart';
import './home.screen.dart';
import '../blocs/user/user_bloc.dart';
import '../cores/user.dart';

class LandingScreen extends StatefulWidget {
  
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  UserBloc _bloc;
  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<UserBloc>(context);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      cubit: _bloc,
      builder: (context, state) {
        if (state is UserSuccess) {
          return HomeScreen();
        }

        if (User.hasWallet()) {
          return HomeScreen();
        } else {
          return WelcomeScreen();
        }
      },
    );
  }
}
