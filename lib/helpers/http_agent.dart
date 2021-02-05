import 'dart:async';
import 'package:dio/dio.dart';

import 'interceptors/retry_interceptor.dart';
import 'interceptors/token_interceptor.dart';
import '../models/api_response.mode.dart';

class HTTPAgent {
  static const int _defaultRetryCount = 3;
  static final HTTPAgent _instance = HTTPAgent._internal();
  factory HTTPAgent() => _instance;
  Dio _dio;

  TokenInterceptor _tokenInterceptor = TokenInterceptor();
  RetryInterceptor _retryInterceptor;
  LogInterceptor _logInterceptor = LogInterceptor(responseBody: true, responseHeader: false);

  HTTPAgent._internal() {
    BaseOptions options = new BaseOptions(
      contentType: Headers.formUrlEncodedContentType,
    );
    _dio = Dio(options);

    setInterceptor();
  }

  setInterceptor() {
    _dio.interceptors.add(_logInterceptor);
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

  Future<APIResponse> get(String path) => _request(() => this._dio.get(path));

  Future<APIResponse> post(String path, dynamic data) => _request(() => this._dio.post(path, data: data));

  Future<APIResponse> put(String path, dynamic data) => _request(() => this._dio.put(path, data: data));

  Future<APIResponse> delete(String path, dynamic data) => _request(() => this._dio.delete(path, data: data));

  Future<APIResponse> _request(Function request) async {
    Response res = await request();

    return APIResponse.fromDioResponse(res);
  }
}
