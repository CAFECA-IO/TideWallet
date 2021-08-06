import 'package:dio/dio.dart';

import '../logger.dart';

class TokenInterceptor extends Interceptor {
  String _token;

  bool isTokenExisted() {
    return _token != null;
  }

  void setToken(String token) {
    _token = token;

    Log.info('TokenInterceptor::setToken $_token');
  }

  void clearToken() {
    _token = null;
  }

  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null) {
      options.headers['token'] = _token;
    }

    super.onRequest(options, handler);
  }
}
