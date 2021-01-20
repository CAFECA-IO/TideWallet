import 'package:flutter/material.dart';

import './alert_dialog.dart';

class ErrorDialog extends StatelessWidget {
  final String _text;

  ErrorDialog(this._text);

  @override
  Widget build(BuildContext context) {
    return AlertDialogField(
      _text,
      Image.asset('assets/images/ic_fingerprint_error.png'),
    );
  }
}
