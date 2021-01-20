import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String _text;

  ErrorDialog(this._text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).disabledColor.withOpacity(0.95),
      elevation: 0.3,
      content: Container(
        width: 170.0,
        height: 170.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/images/ic_fingerprint_error.png'),
            Text(_text),
          ],
        ),
      ),
    );
  }
}
