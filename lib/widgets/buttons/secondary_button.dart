import 'package:flutter/material.dart';
import 'package:tidewallet3/theme.dart';

import './base_button.dart';

class PrimaryButton extends BaseButton {
  PrimaryButton(_text, _onPressed,
      {backgroundColor, disableColor, borderColor, iconImg})
      : super(
          _text,
          _onPressed,
          backgroundColor: Colors.transparent,
          disableColor: disableColor ?? MyColors.primary_02,
          borderColor: borderColor ?? MyColors.primary_01,
          iconImg: iconImg,
        );
}
