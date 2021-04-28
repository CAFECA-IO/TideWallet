import 'package:flutter/material.dart';
import 'package:tidewallet3/theme.dart';

import './base_button.dart';

class SecondaryButton extends BaseButton {
  SecondaryButton(
    String _text,
    Function _onPressed, {
    Color backgroundColor,
    Color disableColor,
    Color disabledTextColor,
    bool isEnabled,
    Color borderColor,
    AssetImage iconImg,
    Color textColor,
  }) : super(_text, _onPressed,
            backgroundColor: Colors.transparent,
            disableColor: disableColor,
            disabledTextColor:
                disabledTextColor ?? MyColors.primary_03.withOpacity(0.5),
            isEnabled: isEnabled ?? true,
            borderColor: borderColor ?? MyColors.primary_01,
            iconImg: iconImg,
            textColor: textColor ?? MyColors.primary_01);
}
