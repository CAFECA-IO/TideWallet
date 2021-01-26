import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/backup/backup_bloc.dart';
import '../widgets/settings/backup.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/verify_password_dialog.dart';
import '../helpers/i18n.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BackupBloc _backupBloc;
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
    _backupBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ],
            ),
          ),
          child: Text(''),
        ),
        ListView(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          children: [
            _section('安全中心', [
              _item('重設錢包密碼', () {
                // TODO: Navigate to screen
                print('ಠ_ಠ');
              }),
              BackupSetting(
                _item(
                  t('setting_backup'),
                  () {
                    DialogContorller.showUnDissmissible(
                      context,
                      VerifyPasswordDialog(
                        (String pwd) {
                          _backupBloc.add(VerifyBackupPassword(pwd));
                        },
                        (String pwd) {
                          DialogContorller.dismiss(context);
                        },
                      ),
                    );
                  },
                ),
              )
            ]),
            _section('一般設定', [
              _item('法幣單位', () {
                // TODO: Navigate to screen
                print('Σ( ° △ °|||)');
              })
            ]),
            _section('關於', [
              _item('建議與反饋', () {
                // TODO: Navigate to screen
                print('Σ( ° △ °|||)');
              }),
              _item('服務條款與隱私權政策', () {
                // TODO: Navigate to screen
                print('Σ( ° △ °|||)');
              })
            ])
          ],
        ),
      ],
    );
  }
}
