import 'package:flutter/material.dart';

class DialogController {
  static const Color _barrierColor = Colors.transparent;

  static show(BuildContext ctx, Widget dialog, {Function? onDismiss}) {
    showDialog(
        barrierColor: _barrierColor,
        context: ctx,
        builder: (context) => dialog).then(
      (value) {
        if (onDismiss != null) onDismiss();
      },
    );
  }

  static showUnDissmissible(BuildContext ctx, Widget dialog) {
    showDialog(
        barrierDismissible: false,
        barrierColor: _barrierColor,
        context: ctx,
        builder: (context) => dialog);
  }

  static dismiss(BuildContext ctx) {
    Navigator.of(ctx).pop();
  }
}
