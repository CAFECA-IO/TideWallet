import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import './welcome.screen.dart';
import './home.screen.dart';
import '../repositories/user_repository.dart';
import '../blocs/user/user_bloc.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  UserBloc _bloc;
  UserRepository _repo;

  @override
  void didChangeDependencies() {
    _repo = Provider.of<UserRepository>(context);
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
      builder: (context, state) {
        if (state is UserSuccess) {
          return HomeScreen();
        }

        if (_repo.user.hasWallet) {
          return HomeScreen();
        } else {
          return WelcomeScreen();
        }
      },
    );
  }
}
