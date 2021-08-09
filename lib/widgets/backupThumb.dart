import 'package:flutter/material.dart';

import './buttons/primary_button.dart';
import '../helpers/i18n.dart';

final t = I18n.t;

class BackupThumb extends StatelessWidget {
  final Function toBackup;

  BackupThumb(this.toBackup);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      width: MediaQuery.of(context).size.width - 20.0,
      height: 80.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: <Color>[
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ImageIcon(
            AssetImage('assets/images/icons/ic_notification_tip.png'),
            size: 44.0,
            color: Colors.white,
          ),
          SizedBox(width: 6.0),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t('backup_message_1'),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    )),
                Text(t('backup_message_2'),
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(color: Colors.white))
              ]),
          Spacer(),
          PrimaryButton(
            t('backup_now'),
            () {
              this.toBackup();
            },
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            backgroundColor: Theme.of(context).hintColor,
            borderColor: Theme.of(context).hintColor,
            fontSize: 14.0,
          )
        ],
      ),
    );
  }
}
