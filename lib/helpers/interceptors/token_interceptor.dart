import 'package:dio/dio.dart';

import '../logger.dart';

class TokenInterceptor extends Interceptor {
  String _token;

  bool isTokenExisted() {
    return _token != null;
  }

  void setToken(String token) {
    _token = token;

    Log.info('ToeknInterceptor::setToekn $_token');
  }

  void clearToken() {
    _token = null;
  }

  Future onRequest(RequestOptions options) {
    if (_token != null) {
      options.headers['token'] = _token;
    }

    return super.onRequest(options);
  }
}