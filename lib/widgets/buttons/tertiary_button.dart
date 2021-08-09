import 'package:flutter/material.dart';
import 'package:tidewallet3/theme.dart';

import 'base_button.dart';

class TertiaryButton extends BaseButton {
  TertiaryButton(
    String _text,
    Function()? _onPressed, {
    Color? backgroundColor,
    Color? disableColor,
    Color? borderColor,
    AssetImage? iconImg,
    Color? textColor,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
  }) : super(_text, _onPressed,
            backgroundColor: backgroundColor ?? MyColors.font_01,
            disableColor: disableColor ?? MyColors.font_01,
            borderColor: borderColor ?? MyColors.font_01,
            borderRadius: borderRadius ?? 0,
            padding: padding ?? EdgeInsets.symmetric(vertical: 18),
            iconImg: iconImg,
            textColor: textColor);
}
