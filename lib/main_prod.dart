import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'index.dart';
void main() async {
  runApp(MyApp());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}
