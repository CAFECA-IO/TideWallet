import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyToolTip extends StatelessWidget {
  final Widget child;
  final String text;

  CopyToolTip({this.child, this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Tooltip(preferBelow: false, message: "Copy", child: child),
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
      },
    );
  }
}
