import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import './repositories/account_repository.dart';
import './repositories/transaction_repository.dart';
import './repositories/user_repository.dart';
import './screens/currency.screen.dart';
import './screens/landing.screen.dart';
import './screens/restore_wallet.screen.dart';
import './screens/wallet_connect.screen.dart';
import './screens/create_transaction.screen.dart';
import './screens/transaction_preview.screen.dart';
import './screens/scan_wallet.screen.dart';
import './screens/scan_address.screen.dart';
import './screens/add_currency.screen.dart';
import './screens/transaction_list.screen.dart';
import './screens/transaction_detail.screen.dart';
import './screens/receive.screen.dart';
import './screens/setting_fiat.screen.dart';
import './screens/feedback.screen.dart';
import './screens/terms.screen.dart';
import './screens/update_password.screen.dart';
import './blocs/fiat/fiat_bloc.dart';
import './blocs/account/account_bloc.dart';
import './blocs/delegate.dart';
import './blocs/user/user_bloc.dart';
import './blocs/transaction/transaction_bloc.dart';
// import './blocs/transaction_status/transaction_status_bloc.dart';
import './blocs/restore_wallet/restore_wallet_bloc.dart';
import './blocs/backup/backup_bloc.dart';
import './blocs/receive/receive_bloc.dart';
// import './blocs/update_password/update_password_bloc.dart';
import './helpers/i18n.dart';
import './repositories/trader_repository.dart';
import './database/db_operator.dart';
import 'theme.dart';

void main() async {
  Bloc.observer = ObserverDelegate();

  runApp(MyApp());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await DBOperator().init();
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
          ),
          Provider<TraderRepository>(
            create: (_) => TraderRepository(),
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
                Provider.of<TraderRepository>(context, listen: false),
              ),
            ),
            // BlocProvider<TransactionStatusBloc>(
            //   create: (BuildContext context) => TransactionStatusBloc(
            //     Provider.of<TransactionRepository>(context, listen: false),
            //     Provider.of<TraderRepository>(context, listen: false),
            //   ),
            // ),
            BlocProvider<RestoreWalletBloc>(
              create: (BuildContext context) => RestoreWalletBloc(
                Provider.of<UserRepository>(context, listen: false),
              ),
            ),
            BlocProvider<AccountBloc>(
              create: (BuildContext context) => AccountBloc(
                Provider.of<AccountRepository>(context, listen: false),
                Provider.of<TraderRepository>(context, listen: false),
              ),
            ),
            BlocProvider<FiatBloc>(
              create: (BuildContext context) => FiatBloc(
                Provider.of<TraderRepository>(context, listen: false),
              )..add(GetFiatList()),
            ),
            BlocProvider<BackupBloc>(
              create: (BuildContext context) => BackupBloc(
                Provider.of<UserRepository>(context, listen: false),
              )..add(CheckBackup()),
            ),
            BlocProvider<ReceiveBloc>(
              create: (BuildContext context) => ReceiveBloc(
                Provider.of<AccountRepository>(context, listen: false),
              ),
            ),
            // BlocProvider<UpdatePasswordBloc>(
            //   create: (BuildContext context) => UpdatePasswordBloc(
            //     Provider.of<UserRepository>(context, listen: false),
            //   ),
            // ),
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
    CreateTransactionScreen.routeName: (context) => CreateTransactionScreen(),
    TransactionPreviewScreen.routeName: (context) => TransactionPreviewScreen(),
    RestoreWalletScreen.routeName: (context) => RestoreWalletScreen(),
    ScanWalletScreen.routeName: (conte) => ScanWalletScreen(),
    ScanAddressScreen.routeName: (conte) => ScanAddressScreen(),
    TransactionListScreen.routeName: (context) => TransactionListScreen(),
    TransactionDetailScreen.routeName: (context) => TransactionDetailScreen(),
    CurrencyScreen.routeName: (context) => CurrencyScreen(),
    AddCurrencyScreen.routeName: (context) => AddCurrencyScreen(),
    ReceiveScreen.routeName: (context) => ReceiveScreen(),
    SettingFiatScreen.routeName: (context) => SettingFiatScreen(),
    WalletConnectScreen.routeName: (context) => WalletConnectScreen(),
    UpdatePasswordScreen.routeName: (context) => UpdatePasswordScreen(),
    FeedbackScreen.routeName: (context) => FeedbackScreen(),
    TermsScreen.routeName: (context) => TermsScreen(),
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
