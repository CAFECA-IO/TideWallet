import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NormalInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function validator;
  final Function onChange;
  final double fontSize;

  NormalInput(
      {this.label,
      this.controller,
      this.validator,
      this.onChange,
      this.fontSize});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r"\s")),
        FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)$')),
      ],
      keyboardType: TextInputType.number,
      onChanged: onChange,
      validator: validator,
      textInputAction: TextInputAction.done,
      style: TextStyle(fontSize: fontSize ?? 16.0),
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(8.0),
        labelStyle: TextStyle(fontSize: 14.0, color: Color(0xFF888888)),
        labelText: label,
        errorStyle: TextStyle(color: Colors.red, fontSize: 10.0),
      ),
    );
  }
}
