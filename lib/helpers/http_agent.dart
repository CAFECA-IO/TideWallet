import 'dart:async';
import 'package:dio/dio.dart';

import 'interceptors/retry_interceptor.dart';
import 'interceptors/token_interceptor.dart';

class HTTPAgent {
  static const int _defaultRetryCount = 3;
  static final HTTPAgent _instance = HTTPAgent._internal();
  factory HTTPAgent() => _instance;
  Dio _dio;
  TokenInterceptor _tokenInterceptor = TokenInterceptor();
  RetryInterceptor _retryInterceptor;

  HTTPAgent._internal() {
    BaseOptions options = new BaseOptions(
      contentType: Headers.formUrlEncodedContentType,
    );
    _dio = Dio(options);

    setInterceptor();
  }

  setInterceptor() {
    _dio.interceptors.add(_tokenInterceptor);

    _retryInterceptor =  RetryInterceptor(
      this._dio,
      options: const RetryOptions(
        retryCount: _defaultRetryCount,
        sleepTime: const Duration(seconds: 1),
      ),
    );
    _dio.interceptors.add(_retryInterceptor);
  }

  void setToken(String token) {
    _tokenInterceptor.setToken(token);
  }

  Future<Response> get(String path) {
    return this._dio.get(path);
  }

  Future<Response> post(String path, dynamic data) {
    return this._dio.post(path, data: data);
  }

  Future<Response> put(String path, dynamic data) {
    return this._dio.put(path, data: data);
  }

  Future<Response> delete(String path, dynamic data) {
    return this._dio.delete(path, data: data);
  }
}
