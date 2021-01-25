import 'package:flutter/material.dart';

abstract class BaseButton extends StatelessWidget {
  final String _text;
  final Function _onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color disableColor;
  final Color textColor;
  final AssetImage iconImg;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  BaseButton(
    this._text,
    this._onPressed, {
    this.iconImg,
    this.backgroundColor,
    this.disableColor,
    this.borderColor,
    this.textColor,
    this.padding,
    this.fontSize
  });
  
  @override
  Widget build(BuildContext context) {
    return FlatButton(
        disabledTextColor: Colors.white,
        disabledColor: this.disableColor,
        color: backgroundColor,
        padding: this.padding ?? const EdgeInsets.symmetric(horizontal: 32.5, vertical: 13.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(200.0),
          side: BorderSide(
            color: this.borderColor,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        textColor: Theme.of(context).textTheme.button.color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            this.iconImg != null ? ImageIcon(this.iconImg, color: Theme.of(context).textTheme.button.color, size: 20.0,) : SizedBox(width: 0), 
            this.iconImg != null ? SizedBox(width: 14.0,) : SizedBox(),
            Text(
              _text,
              style: TextStyle(fontSize: this.fontSize ?? 16.0, color: this.textColor),
            ),
          ],
        ),
        onPressed: _onPressed);
  }
}
