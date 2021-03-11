import 'package:flutter/material.dart';

import './account_currency.screen.dart';
import './investment.screen.dart';
import './wallet_connect.screen.dart';
import './credit_card.screen.dart';
import './settings.screen.dart';
import '../widgets/appBar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../helpers/i18n.dart';

final t = I18n.t;

class HomeScreenContent {
  final String routeName;
  final Widget widget;
  final String title;
  final IconData iconData;
  final String bottomText;

  HomeScreenContent(this.widget, this.routeName, this.title,
      {this.iconData: Icons.home, this.bottomText: ''});
}

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  // HomeScreen({Key key, this.title}) : super(key: key);
  // final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  PageController _pageController = PageController();
  int _selectedIndex = 0;
  // bool _isInit = true;
  // HDWalletRepository _hdWalletRepository;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // _hdWalletRepository = Provider.of<HDWalletRepository>(context);
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<HomeScreenContent> _screens = [
      HomeScreenContent(AccountCurrencyScreen((int index) {
        _pageController.jumpToPage(index);
        setState(
          () {
            _selectedIndex = index;
          },
        );
      }), AccountCurrencyScreen.routeName, t('total_asset'),
          iconData: Icons.account_balance_wallet, bottomText: ''),
      HomeScreenContent(
          InvestmentScreen(), InvestmentScreen.routeName, t('invest'),
          iconData: Icons.assessment_outlined, bottomText: ''),
      HomeScreenContent(
          CreditCardScreen(), CreditCardScreen.routeName, t('credit_card'),
          iconData: Icons.credit_card, bottomText: ''),
      HomeScreenContent(
          SettingsScreen(), SettingsScreen.routeName, t('setting'),
          iconData: Icons.settings, bottomText: ''),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: GeneralAppbar(
          title: _screens[_selectedIndex].title,
          routeName: _screens[_selectedIndex].routeName),
      body: PageView(
        controller: _pageController,
        // onPageChanged: _onPageChanged,
        children: _screens.map((s) => s.widget).toList(),
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CBottomAppBar(
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).primaryColor,
        notchedShape: CircularNotchedRectangle(),
        onTabSelected: (int index) {
          _pageController.jumpToPage(index);
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        items: _screens
            .map((s) =>
                CBottomAppBarItem(iconData: s.iconData, text: s.bottomText))
            .toList(),
        iconSize: 20,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        // backgroundColor: MyColors.ui_01,
        onPressed: () async {
          Navigator.of(context).pushNamed(WalletConnectScreen.routeName);
        },
        child: Icon(
          Icons.center_focus_weak,
          color: Theme.of(context).primaryColor,
        ),
        elevation: 3.0,
      ),
    );
  }
}
