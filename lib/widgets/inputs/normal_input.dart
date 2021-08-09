import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NormalInput extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChange;
  final Function()? onTap;
  final double? fontSize;
  final bool readOnly;
  final FocusNode? focusNode;

  NormalInput({
    this.focusNode,
    this.label,
    this.controller,
    this.validator,
    this.onChange,
    this.onTap,
    this.fontSize,
    this.readOnly: false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      textAlign: TextAlign.end,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r"\s")),
        FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)$')),
      ],
      readOnly: readOnly,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      focusNode: focusNode,
      controller: controller,
      onChanged: onChange,
      validator: validator,
      textInputAction: TextInputAction.done,
      style: TextStyle(fontSize: fontSize ?? 16.0),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(8.0),
        labelStyle: TextStyle(fontSize: 14.0, color: Color(0xFF888888)),
        labelText: label,
        errorStyle: TextStyle(color: Colors.red, fontSize: 10.0),
      ),
    );
  }
}
