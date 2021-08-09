import 'package:flutter/material.dart';
import 'package:tidewallet3/theme.dart';

import './base_button.dart';

class PrimaryButton extends BaseButton {
  PrimaryButton(
    String _text,
    Function()? _onPressed, {
    Color? backgroundColor,
    Color? disableColor,
    Color? borderColor,
    AssetImage? iconImg,
    Widget? icon,
    Color? textColor,
    EdgeInsetsGeometry? padding,
    double? fontSize,
  }) : super(_text, _onPressed,
            backgroundColor: backgroundColor ?? MyColors.primary_01,
            disableColor: disableColor ?? MyColors.primary_02,
            borderColor: borderColor ?? MyColors.primary_01,
            iconImg: iconImg,
            textColor: textColor,
            padding: padding,
            fontSize: fontSize,
            icon: icon);
}
