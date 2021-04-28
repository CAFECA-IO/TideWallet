import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alice/alice.dart';

import '../blocs/backup/backup_bloc.dart';
import '../screens/landing.screen.dart';
import '../screens/update_password.screen.dart';
import '../screens/feedback.screen.dart';
import '../screens/terms.screen.dart';
import '../screens/buy_tide_point.screen.dart';
import '../widgets/header.dart';
import '../widgets/settings/backup.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/verify_password_dialog.dart';
import '../widgets/version.dart';
import '../widgets/settings/fiat.dart';
import '../widgets/settings/reset.dart';
import '../helpers/i18n.dart';
import '../helpers/http_agent.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BackupBloc _backupBloc;
  Alice alice;

  final t = I18n.t;

  Widget _item(String _title, Function _onTap) {
    return InkWell(
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsets.only(
          right: 20.0,
          left: 4.0,
          top: 10.0,
          bottom: 10.0,
        ),
        // decoration: BoxDecoration(
        //   border: Border(
        //     bottom: BorderSide(color: Theme.of(context).dividerColor),
        //   ),
        // ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_title),
            ImageIcon(
              AssetImage('assets/images/icons/ic_arrow_right_normal.png'),
              color: Theme.of(context).textTheme.subtitle2.color,
            )
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> items) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              right: 20.0,
              left: 4.0,
              top: 10.0,
              bottom: 10.0,
            ),
            width: double.infinity,
            child: Text(
              title,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
          ),
          ...items
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    _backupBloc = BlocProvider.of<BackupBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            children: [
              _section(t('setting_security'), [
                ResetSetting(_item(t('setting_reset'), null)),
              ]),
              _section(t('setting_normal'),
                  [FiatSetting(_item(t('setting_fiat'), null))]),
              _section(t('setting_about'), [
                _item(t('setting_feedback'), () {
                  Navigator.of(context).pushNamed(FeedbackScreen.routeName);
                }),
                _item(t('setting_term'), () {
                  Navigator.of(context).pushNamed(TermsScreen.routeName);
                }),
              ]),
              _section(t('developer_option'), [
                _item(t('debug_mode'), () {
                  alice = Alice(
                      showNotification: true,
                      navigatorKey: navigatorKey,
                      darkTheme: true);
                  HTTPAgent().setAlice(alice);
                  Navigator.of(context).pushNamed(LandingScreen.routeName,
                      arguments: {"debugMode": true});
                }),
                _item('Buy TideWallet Point', () {
                  Navigator.of(context).pushNamed(BuyTidePointScreen.routeName);
                })
              ]),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Version(),
              )
            ],
          ),
        ),
      ],
    );
  }
}
