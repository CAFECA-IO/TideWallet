import 'package:flutter/material.dart';


class MyColors {
  static const primary_01 = Color(0xFF3BB3AB);
  static const primary_02 = Color(0xFF4ECDC4);
  static const primary_03 = Color(0xFF446CB3);
  static const primary_04 = Color(0xFFFF5730);
  static const primary_05 = Color(0xFFFF1212);

  static const secondary_01 = Color(0xFF555555);
  static const secondary_02 = Color(0xFF9B9B9B);
  static const secondary_03 = Color(0xFFC2C2C2);
  static const secondary_04 = Color(0xFFCECECE);
  static const secondary_05 = Color(0xFFECECEC);
  static const secondary_06 = Color(0xFFF7F8F9);

  static const font_01 = Colors.white;
}

TextTheme myTextTheme = TextTheme(
  headline1: TextStyle(color: MyColors.secondary_01, fontSize: 20.0, letterSpacing: 0.4, fontWeight: FontWeight.bold),
  bodyText1: TextStyle(color: MyColors.secondary_01),
  button: TextStyle(color: MyColors.font_01),
);

ThemeData myThemeData = ThemeData(
  primaryColor: MyColors.primary_02,
  primaryColorLight: MyColors.primary_01,
  accentColor: MyColors.primary_03,
  errorColor: MyColors.primary_05,
  hintColor: MyColors.primary_04,
  textTheme: myTextTheme,
  cursorColor: MyColors.secondary_03
);

ThemeData myDarkThemeData = ThemeData();

ShapeBorder bottomSheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(10.0),
    topRight: Radius.circular(10.0),
  ),
);