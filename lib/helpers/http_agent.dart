import 'dart:async';
import 'package:alice/alice.dart';
import 'package:dio/dio.dart';

import 'interceptors/error_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/token_interceptor.dart';
import '../models/auth.model.dart';
import '../models/api_response.mode.dart';
import '../constants/endpoint.dart';
import 'prefer_manager.dart';

class HTTPAgent {
  static const int _defaultRetryCount = 3;
  static final HTTPAgent _instance = HTTPAgent._internal();
  factory HTTPAgent() => _instance;
  Dio _dio;
  PrefManager _prefManager = PrefManager();
  Alice _alice;

  TokenInterceptor _tokenInterceptor = TokenInterceptor();
  RetryInterceptor _retryInterceptor;
  LogInterceptor _logInterceptor =
      LogInterceptor(responseBody: true, responseHeader: false);

  HTTPAgent._internal() {
    BaseOptions options = new BaseOptions(
      contentType: Headers.formUrlEncodedContentType,
    );
    _dio = Dio(options);

    setInterceptor();
  }

  setAlice(Alice alice) {
    _alice = alice;
    _dio.interceptors.add(_alice.getDioInterceptor());
  }

  setInterceptor() {
    _dio.interceptors.add(_logInterceptor);
    _dio.interceptors.add(_tokenInterceptor);
    _dio.interceptors.add(ErrorInterceptor(this._dio, this._refreshToken));
    _retryInterceptor = RetryInterceptor(
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

  Future<APIResponse> post(String path, dynamic data) =>
      _request(() => this._dio.post(path, data: data));

  Future<APIResponse> put(String path, dynamic data) =>
      _request(() => this._dio.put(path, data: data));

  Future<APIResponse> delete(String path, dynamic data) =>
      _request(() => this._dio.delete(path, data: data));

  Future<APIResponse> _request(Function request) async {
    Response res = await request();

    return APIResponse.fromDioResponse(res);
  }

  Future<bool> _refreshToken() async {
    AuthItem tk = await this._prefManager.getAuthItem();

    _dio.interceptors.requestLock.lock();
    _dio.interceptors.responseLock.lock();

    APIResponse res = await this.post(
        Endpoint.url, {'token': tk.token, 'tokenSecret': tk.tokenSecret});
    _dio.interceptors.requestLock.unlock();
    _dio.interceptors.responseLock.unlock();

    if (res.success) {
      final auth = AuthItem.fromJson(res.data);
      this._prefManager.setAuthItem(auth);
      this._tokenInterceptor.setToken(auth.token);
    }

    return res.success;
  }
}
