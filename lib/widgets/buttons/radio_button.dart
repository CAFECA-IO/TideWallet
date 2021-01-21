import 'package:flutter/material.dart';
import '../../helpers/i18n.dart';

import '../../theme.dart';
import 'base_button.dart';
import 'primary_button.dart';

class RadioGroupButton extends StatefulWidget {
  final List<List<dynamic>> function;
  RadioGroupButton(this.function);
  @override
  _RadioGroupButtonState createState() => _RadioGroupButtonState();
}

class _RadioGroupButtonState extends State<RadioGroupButton> {
  final t = I18n.t;
  int _isSelectedIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: widget.function
              .asMap()
              .map(
                (index, element) => MapEntry(
                  index,
                  RadioButton(element[0], () {
                    setState(() {
                      _isSelectedIndex = index;
                    });
                    element[1]();
                  },
                      isEnabled: _isSelectedIndex == index ? true : false,
                      minWidth:
                          (MediaQuery.of(context).size.width - 32 - 8.5 * 2) /
                              3),
                ),
              )
              .values
              .toList()),
    );
  }
}

class RadioButton extends BaseButton {
  RadioButton(String _text, Function _onPressed,
      {Color backgroundColor,
      Color disableColor,
      Color disabledTextColor,
      Color borderColor,
      AssetImage iconImg,
      Color textColor,
      bool isEnabled,
      TextStyle textStyle,
      Padding padding,
      double minWidth})
      : super(_text, _onPressed,
            backgroundColor: backgroundColor ?? MyColors.primary_01,
            disabledTextColor: disabledTextColor ?? MyColors.secondary_02,
            disableColor: disableColor ?? MyColors.secondary_05,
            borderColor: borderColor ?? MyColors.primary_01,
            textStyle: textStyle ?? TextStyle(fontSize: 14.0, color: textColor),
            padding:
                padding ?? EdgeInsets.symmetric(horizontal: 0, vertical: 12.0),
            iconImg: iconImg,
            textColor: textColor,
            isEnabled: isEnabled ?? true,
            minWidth: minWidth ?? 0);
}
