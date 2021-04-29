import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'blocs/delegate.dart';

import 'index.dart';

void main() async {

  runApp(MyApp());
  Bloc.observer = ObserverDelegate();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}