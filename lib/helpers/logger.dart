import 'package:logger/logger.dart';
import 'dart:convert';
import 'dart:io';

import '../constants/log_config.dart';

class Log {
  static final Log _instance = Log._internal();
  factory Log() => _instance;

  Logger _stackLogger;
  Logger _noStacklogger;

  Log._internal() {
    _noStacklogger = Logger(
        printer: PrettyPrinter(methodCount: 0),
        level: bool.fromEnvironment('dart.vm.product')
            ? Level.warning
            : Level.verbose);
    _stackLogger = Logger(
        printer: PrettyPrinter(methodCount: 8),
        level: bool.fromEnvironment('dart.vm.product')
            ? Level.warning
            : Level.verbose);
  }

  static void setLogLevel(Level level) => Logger.level = level;

  static void verbose(dynamic msg) {
    if (Config.logLevel > 0) return;
    _instance._noStacklogger.v(
        "$msg (${StackTrace.current.toString().split('\n')[1].split('(')[1].split(')')[0]})");
    logToServer('\x1B[32m[VERBOSE]\x1B[0m $msg');
  }

  static void debug(dynamic msg) {
    if (Config.logLevel > 0) return;
    _instance._noStacklogger.d(
        "$msg (${StackTrace.current.toString().split('\n')[1].split('(')[1].split(')')[0]})");
    logToServer('\x1B[32m[DEBUG]\x1B[0m $msg');
  }

  static void info(dynamic msg) {
    if (Config.logLevel > 1) return;
    _instance._noStacklogger.i("$msg (${StackTrace.current.toString().split('\n')[1].split('(')[1].split(')')[0]})");
    logToServer('\x1B[94m[INFO]\x1B[0m $msg');
  }

  static void warning(dynamic msg) {
    if (Config.logLevel > 2) return;
    _instance._stackLogger.w(
        "$msg (${StackTrace.current.toString().split('\n')[1].split('(')[1].split(')')[0]})");
    logToServer('\x1B[33m[WARN]\x1B[0m $msg');
  }

  static void error(dynamic msg) {
    if (Config.logLevel > 3) return;
    _instance._stackLogger.e(
        "$msg (${StackTrace.current.toString().split('\n')[1].split('(')[1].split(')')[0]})");
    logToServer('\x1B[91m[ERROR]\x1B[0m $msg');
  }

  static void logToServer(dynamic data) async {
    if (!Config.remoteLog) return;

    Map<String, String> requestBody = {"log": data};
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse(Config.logServer));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(requestBody)));
    HttpClientResponse response = await request.close();
    await response.transform(utf8.decoder).join();
    httpClient.close();
  }
}
