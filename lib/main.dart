import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import './screens/currency.screen.dart';
import './screens/landing.screen.dart';
import './screens/restore_wallet.screen.dart';
import './screens/wallet_connect.screen.dart';
import './screens/create_transaction.screen.dart';
import './screens/transaction_preview.screen.dart';
import './repositories/account_repository.dart';
import './repositories/transaction_repository.dart';
import './screens/scan_wallet.screen.dart';
import './screens/transaction_list.screen.dart';
import './screens/transaction_detail.screen.dart';
import './screens/receive.screen.dart';
import './repositories/user_repository.dart';
import './repositories/account_repository.dart';
import './blocs/account/account_bloc.dart';
import './blocs/delegate.dart';
import './blocs/user/user_bloc.dart';
import './blocs/transaction/transaction_bloc.dart';
import './blocs/restore_wallet/restore_wallet_bloc.dart';
import './blocs/backup/backup_bloc.dart';
import './helpers/i18n.dart';
import 'theme.dart';

void main() {
  Bloc.observer = ObserverDelegate();

  runApp(MyApp());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: MultiProvider(
        providers: [
          Provider<UserRepository>(
            create: (_) => UserRepository(),
          ),
          Provider<AccountRepository>(
            create: (_) => AccountRepository(),
          ),
          Provider<TransactionRepository>(
            create: (_) => TransactionRepository(),
          )
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<UserBloc>(
              create: (BuildContext context) => UserBloc(
                Provider.of<UserRepository>(context, listen: false),
              ),
            ),
            BlocProvider<TransactionBloc>(
              create: (BuildContext context) => TransactionBloc(
                Provider.of<TransactionRepository>(context, listen: false),
              ),
            ),
            BlocProvider<RestoreWalletBloc>(
              create: (BuildContext context) => RestoreWalletBloc(
                Provider.of<UserRepository>(context, listen: false),
              ),
            ),
            BlocProvider<AccountBloc>(
              create: (BuildContext context) => AccountBloc(
                Provider.of<AccountRepository>(context, listen: false),
              ),
            ),
            BlocProvider<BackupBloc>(
              create: (BuildContext context) => BackupBloc(
                Provider.of<UserRepository>(context, listen: false),
              )..add(CheckBackup()),
            )
          ],
          child: _material,
        ),
      ),
    );
  }
}

MaterialApp _material = MaterialApp(
  title: 'TideWallet3',
  theme: myThemeData,
  routes: {
    '/': (context) => LandingScreen(),
    // '/': (context) => TransactionListScreen(),
    CreateTransactionScreen.routeName: (context) => CreateTransactionScreen(),
    TransactionPreviewScreen.routeName: (context) => TransactionPreviewScreen(),
    RestoreWalletScreen.routeName: (context) => RestoreWalletScreen(),
    ScanWalletScreen.routeName: (conte) => ScanWalletScreen(),
    TransactionListScreen.routeName: (context) => TransactionListScreen(),
    TransactionDetailScreen.routeName: (context) => TransactionDetailScreen(),
    CurrencyScreen.routeName: (context) => CurrencyScreen(),
    ReceiveScreen.routeName: (context) => ReceiveScreen(),
    WalletConnectScreen.routeName: (context) => WalletConnectScreen(),
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
