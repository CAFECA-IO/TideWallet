import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './screens/home.screen.dart';
import './screens/landing.screen.dart';
import './screens/wallet_connect.screen.dart';
import './helpers/i18n.dart';
import 'theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        },
        child: _material);
  }
}

MaterialApp _material = MaterialApp(
  title: 'TideWallet3',
  theme: myThemeData,
  routes: {
    '/': (context) => LandingScreen(),
    // '/': (context) => HomeScreen(),
    WalletConnectScreen.routeName: (context) => WalletConnectScreen()
  },
  localizationsDelegates: [
    const I18nDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    const Locale('en'),
    const Locale('ja', 'JP'),
  ],
  localeListResolutionCallback: (deviceLocales, supportedLocales) {
    Locale locale = supportedLocales.toList()[0];
    for (Locale deviceLocale in deviceLocales) {
      if (I18nDelegate().isSupported(deviceLocale)) {
        locale = deviceLocale;
        break;
      }
    }
    Intl.defaultLocale = locale.languageCode;
    return locale;
  },
);
