import 'package:flutter/material.dart';

import 'primary_button.dart';

class RadioButton extends StatefulWidget {
  @override
  _RadioButtonState createState() => _RadioButtonState();
}

class _RadioButtonState extends State<RadioButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Flex(
        direction: Axis.horizontal,
        children: [
          PrimaryButton('Slow', () {}),
          PrimaryButton('Standard', () {}),
          PrimaryButton('Fast', () {}),
        ],
      ),
    );
  }
}
