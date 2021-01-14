import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './screens/home.screen.dart';
import './screens/wallet_connect.screen.dart';
import './helpers/i18n.dart';

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
  title: 'Flutter Demo',
  theme: ThemeData(
    // This is the theme of your application.
    //
    // Try running your application with "flutter run". You'll see the
    // application has a blue toolbar. Then, without quitting the app, try
    // changing the primarySwatch below to Colors.green and then invoke
    // "hot reload" (press "r" in the console where you ran "flutter run",
    // or simply save your changes to "hot reload" in a Flutter IDE).
    // Notice that the counter didn't reset back to zero; the application
    // is not restarted.
    primarySwatch: Colors.blue,
    // This makes the visual density adapt to the platform that you run
    // the app on. For desktop platforms, the controls will be smaller and
    // closer together (more dense) than on mobile platforms.
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  routes: {
    '/': (context) => HomeScreen(),
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
