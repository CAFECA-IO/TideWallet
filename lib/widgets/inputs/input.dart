import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Input extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? suffixText;
  final String? Function(String?)? validator;
  final bool readOnly;
  final Function()? onTap;
  final Widget? suffix;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final String? hintText;
  final AutovalidateMode? autovalidate;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatter;

  Input({
    this.controller,
    this.labelText,
    this.suffixText,
    this.validator,
    this.readOnly: false,
    this.onTap,
    this.suffix,
    this.suffixIcon,
    this.onChanged,
    this.focusNode,
    this.hintText,
    this.autovalidate: AutovalidateMode.always,
    this.keyboardType: TextInputType.text,
    this.inputFormatter: const [],
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        inputFormatters: inputFormatter,
        keyboardType: keyboardType,
        focusNode: focusNode,
        controller: controller,
        // textAlignVertical: TextAlignVertical.bottom,
        decoration: InputDecoration(
          contentPadding: suffixIcon == null
              ? EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)
              : EdgeInsets.only(left: 8.0, bottom: 8.0),
          labelText: labelText,
          labelStyle: TextStyle(color: Theme.of(context).accentColor),
          suffixText: suffixText,
          suffix: suffix,
          suffixIcon: suffixIcon,
          hintText: hintText,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColorLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).cursorColor),
          ),
        ),
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        autovalidateMode: AutovalidateMode.always);
  }
}
