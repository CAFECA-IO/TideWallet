import 'package:flutter/material.dart';

abstract class BaseButton extends StatelessWidget {
  final String _text;
  final Function _onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color disableColor;
  final Color disabledTextColor;
  final Color textColor;
  final AssetImage iconImg;
  final EdgeInsetsGeometry padding;
  final bool isEnabled;
  final TextStyle textStyle;
  final double minWidth;
  final double borderRadius;

  BaseButton(this._text, this._onPressed,
      {this.iconImg,
      this.backgroundColor,
      this.disableColor,
      this.disabledTextColor,
      this.borderColor,
      this.textColor,
      this.padding,
      this.isEnabled = true,
      this.textStyle,
      this.minWidth,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        minWidth: minWidth ?? 0,
        disabledColor: this.disableColor,
        disabledTextColor: this.disabledTextColor,
        color: isEnabled ? backgroundColor : disableColor,
        padding: this.padding != null
            ? this.padding
            : const EdgeInsets.symmetric(horizontal: 32.5, vertical: 13.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(this.borderRadius ?? 200.0),
          side: BorderSide(
            color: isEnabled ? this.borderColor : this.disableColor,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        textColor: isEnabled
            ? Theme.of(context).textTheme.button.color
            : this.disabledTextColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            this.iconImg != null
                ? ImageIcon(
                    this.iconImg,
                    color: this.textColor ??
                        Theme.of(context).textTheme.button.color,
                    size: 20.0,
                  )
                : SizedBox(width: 0),
            SizedBox(
              width: this.iconImg != null ? 14.0 : 0,
            ),
            Text(
              _text,
              style: this.textStyle ??
                  TextStyle(fontSize: 16.0, color: this.textColor),
            ),
          ],
        ),
        onPressed: _onPressed);
  }
}
