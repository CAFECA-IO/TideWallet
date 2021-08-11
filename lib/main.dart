import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'blocs/delegate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import './repositories/account_repository.dart';
import './repositories/transaction_repository.dart';
import './repositories/user_repository.dart';
import './repositories/trader_repository.dart';
import './repositories/invest_repository.dart';
import './repositories/swap_repository.dart';
import './repositories/local_auth_repository.dart';
import './screens/landing.screen.dart';
import './screens/wallet_connect.screen.dart';
import './screens/create_transaction.screen.dart';
import './screens/transaction_preview.screen.dart';
import './screens/scan_address.screen.dart';
import './screens/transaction_list.screen.dart';
import './screens/transaction_detail.screen.dart';
import './screens/receive.screen.dart';
import './screens/setting_fiat.screen.dart';
import './screens/feedback.screen.dart';
import './screens/terms.screen.dart';
import './screens/add_investment.screen.dart';
import './screens/scan.screen.dart';
import './screens/recover_mnemonic.screen.dart';
import './screens/toggle_currency.screen.dart';
import './blocs/fiat/fiat_bloc.dart';
import './blocs/account_currency/account_currency_bloc.dart';
import './blocs/delegate.dart';
import './blocs/user/user_bloc.dart';
import './blocs/toggle_token/toggle_token_bloc.dart';
import './blocs/transaction/transaction_bloc.dart';
import './blocs/transaction_status/transaction_status_bloc.dart';
import './blocs/receive/receive_bloc.dart';
import './blocs/invest_plan/invest_plan_bloc.dart';
import './blocs/local_auth/local_auth_bloc.dart';
import './blocs/invest/invest_bloc.dart';
import './helpers/i18n.dart';
import 'constants/endpoint.dart';
import 'theme.dart';

void main() async {
  runApp(MyApp());
  await Firebase.initializeApp();
  Bloc.observer = ObserverDelegate();
  await Endpoint.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance?.focusManager.primaryFocus?.unfocus();
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
          ),
          Provider<InvestRepository>(
            create: (_) => InvestRepository(),
          ),
          Provider<SwapRepository>(
            create: (_) => SwapRepository(),
          ),
          Provider<LocalAuthRepository>(
            create: (_) => LocalAuthRepository(),
          )
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<UserBloc>(
              create: (BuildContext context) => UserBloc(
                Provider.of<UserRepository>(context, listen: false),
                Provider.of<AccountRepository>(context, listen: false),
              ),
            ),
            BlocProvider<TransactionBloc>(
              create: (BuildContext context) => TransactionBloc(
                Provider.of<TransactionRepository>(context, listen: false),
                Provider.of<TraderRepository>(context, listen: false),
              ),
            ),
            BlocProvider<InvestBloc>(
              create: (BuildContext context) => InvestBloc(
                  Provider.of<InvestRepository>(context, listen: false),
                  Provider.of<UserRepository>(context, listen: false)),
            ),
            BlocProvider<AccountCurrencyBloc>(
              create: (BuildContext context) => AccountCurrencyBloc(
                Provider.of<AccountRepository>(context, listen: false),
                Provider.of<TraderRepository>(context, listen: false),
              ),
            ),
            BlocProvider<InvestPlanBloc>(
              create: (BuildContext context) => InvestPlanBloc(
                Provider.of<InvestRepository>(context, listen: false),
                Provider.of<TraderRepository>(context, listen: false),
              ),
            ),
            BlocProvider<FiatBloc>(
              create: (BuildContext context) => FiatBloc(
                Provider.of<TraderRepository>(context, listen: false),
              )..add(GetFiatList()),
            ),
            BlocProvider<LocalAuthBloc>(
              create: (BuildContext context) => LocalAuthBloc(
                Provider.of<LocalAuthRepository>(context, listen: false),
              )..add(Authenticate()),
            ),
            BlocProvider<ToggleTokenBloc>(
              create: (BuildContext context) => ToggleTokenBloc(
                Provider.of<AccountRepository>(context, listen: false),
              ),
            )
            // BlocProvider<ReceiveBloc>(
            //   create: (BuildContext context) => ReceiveBloc(
            //     Provider.of<AccountRepository>(context, listen: false),
            //   ),
            // ),
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
  debugShowCheckedModeBanner: false,
  title: 'TideWallet3',
  navigatorKey: navigatorKey,
  theme: myThemeData,
  routes: {
    '/': (context) => LandingScreen(),
    LandingScreen.routeName: (context) => LandingScreen(),
    CreateTransactionScreen.routeName: (context) => CreateTransactionScreen(),
    TransactionPreviewScreen.routeName: (context) => TransactionPreviewScreen(),
    ScanAddressScreen.routeName: (conte) => ScanAddressScreen(),
    TransactionListScreen.routeName: (context) => TransactionListScreen(),
    TransactionDetailScreen.routeName: (context) => TransactionDetailScreen(),
    AddInvestmentScreen.routeName: (context) => AddInvestmentScreen(),
    ReceiveScreen.routeName: (context) => ReceiveScreen(),
    SettingFiatScreen.routeName: (context) => SettingFiatScreen(),
    WalletConnectScreen.routeName: (context) => WalletConnectScreen(),
    FeedbackScreen.routeName: (context) => FeedbackScreen(),
    TermsScreen.routeName: (context) => TermsScreen(),
    ScanScreen.routeName: (context) => ScanScreen(),
    RecoverMemonicScreen.routeName: (context) => RecoverMemonicScreen(),
    ToggleCurrencyScreen.routeName: (context) => ToggleCurrencyScreen(),
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
    if (deviceLocales != null)
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
