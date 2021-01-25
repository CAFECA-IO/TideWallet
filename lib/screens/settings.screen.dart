import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/backup/backup_bloc.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/verify_password_dialog.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BackupBloc _backupBloc;

  Widget _item(String _title, Function _onTap) {
    return InkWell(
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsets.only(
            right: 20.0, left: 4.0, top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
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
        Container(
          padding: const EdgeInsets.only(left: 20.0),
          child: ListView(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            children: [
              BlocBuilder<BackupBloc, BackupState>(
                builder: (BuildContext ctx, BackupState state) {
                  if (state is UnBackup) {
                    return _item(
                      '備份錢包',
                      () {
                        DialogContorller.showUnDissmissible(
                          context,
                          VerifyPasswordDialog(
                            (String pwd) {},
                            (String pwd) {
                              DialogContorller.dismiss(context);
                            },
                          ),
                        );
                      },
                    );
                  }

                  Color _color = Theme.of(context).accentColor;

                  return Container(
                    padding: const EdgeInsets.only(
                        right: 20.0, left: 4.0, top: 10.0, bottom: 10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: _color,),
                        SizedBox(width: 24.0,),
                        Text('已備份錢包', style: TextStyle(color: _color),),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
