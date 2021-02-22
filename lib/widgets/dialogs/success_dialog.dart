import 'package:flutter/material.dart';

import './alert_dialog.dart';

class SuccessDialog extends StatelessWidget {
  final String _text;

  SuccessDialog(this._text);

  @override
  Widget build(BuildContext context) {
    return AlertDialogField(
      _text,
      Image.asset('assets/images/img_successful.png'),
    );
  }
}
