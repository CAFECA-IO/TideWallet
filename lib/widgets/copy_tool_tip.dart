import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/i18n.dart';

final t = I18n.t;

class CopyToolTip extends StatelessWidget {
  final Widget child;
  final String text;

  CopyToolTip({this.child, this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Tooltip(preferBelow: false, message: t('copy'), child: child),
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
      },
    );
  }
}
