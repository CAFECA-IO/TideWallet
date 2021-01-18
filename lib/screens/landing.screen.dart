import 'package:flutter/material.dart';

import './welcome.screen.dart';
import './home.screen.dart';
import '../cores/user.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
 
    if (User.hasWallet()) {
      return HomeScreen();
    } else {
      return WelcomeScreen();
    }

    // return Center(
    //   child: CircularProgressIndicator(),
    // );
  }
}
