import 'package:flutter/material.dart';

class AlertDialogField extends StatelessWidget {
  final String _text;
  final Widget _img;

  AlertDialogField(this._text, this._img);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).disabledColor.withOpacity(0.95),
      elevation: 0.3,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).disabledColor),
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      content: Container(
        width: 170.0,
        height: 170.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _img,
            Text(_text),
          ],
        ),
      ),
    );
  }
}