import 'package:dio/dio.dart';

import '../logger.dart';

class ErrorInterceptor extends Interceptor {
  static const KEY = 'code';
  static const NO_ERROR = '00000000';
  static const USER_OCCUPATION = '02000000';
  static const USER_NOT_FOUND = '02000001';
  static const INVALID_ACCESS_TOKEN = '03000000';
  static const EXPIRED_ACCESS_TOKEN = '03000001';
  static const INVALID_ACCESS_TOKEN_SECRET = '03000002';
  static const EXPIRED_ACCESS_TOKEN_SECRET = '03000003';
  static const INVALID_SIGNATURE = '03000004';
  static const BLOCKCHAIN_ID_NOT_FOUND = '04000000';
  static const CURRENCY_ID_NOT_FOUND = '04000001';
  static const BLOCKCHAIN_HAS_NOT_TOKEN = '04000002';
  static const TOKEN_ID_NOT_FOUND = '04000003';
  static const DB_ERROR = '05000000';
  static const PUBLISH_TX_ERROR = '05000001';
  static const UNKNOWN_ERROR = '09000000';

  final Dio dio;
  Function _refreshToken;

  ErrorInterceptor(this.dio, this._refreshToken);
  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    if (response.data[KEY] != NO_ERROR) {
      Log.error(response.data[KEY]);

      switch (response.data[KEY]) {
        case EXPIRED_ACCESS_TOKEN:
          bool success = await this._refreshToken();

          if (success) {
            return await this.dio.request(
                  response.requestOptions.path,
                  cancelToken: response.requestOptions.cancelToken,
                  data: response.requestOptions.data,
                  onReceiveProgress: response.requestOptions.onReceiveProgress,
                  onSendProgress: response.requestOptions.onSendProgress,
                  queryParameters: response.requestOptions.queryParameters,
                  options: Options(
                      method: response.requestOptions.method,
                      headers: response.requestOptions.headers),
                );
          }
          break;
        default:
      }
    }
    return super.onResponse(response, handler);
  }
}
