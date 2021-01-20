import 'package:flutter/material.dart';

import './alert_dialog.dart';
import '../../helpers/i18n.dart';

final t = I18n.t;

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialogField(
      t('dialog_loading'),
      CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
      ),
    );
  }
}
