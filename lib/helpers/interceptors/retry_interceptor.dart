import 'dart:io';
import 'package:dio/dio.dart';

import '../logger.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final RetryOptions options;
  RetryInterceptor(
    this.dio, {
    this.options = const RetryOptions(),
  });

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    var extra = RetryOptions.fromExtra(err.requestOptions) ?? this.options;

    if (_shouldRetry(err, extra)) {
      await Future.delayed(extra.sleepTime);
      Log.warning('Retry::${err.requestOptions.path}');
      extra = extra.copyWith(retryCount: extra.retryCount - 1);
      err.requestOptions.extra = err.requestOptions.extra
        ..addAll(extra.toExtra());

      return await this.dio.request(
            err.requestOptions.path,
            cancelToken: err.requestOptions.cancelToken,
            data: err.requestOptions.data,
            onReceiveProgress: err.requestOptions.onReceiveProgress,
            onSendProgress: err.requestOptions.onSendProgress,
            queryParameters: err.requestOptions.queryParameters,
            options: Options(
                method: err.requestOptions.method,
                headers: err.requestOptions.headers),
          );
    }
    return super.onError(err, handler);
  }

  bool _shouldRetry(DioError err, RetryOptions extra) {
    if (extra.retryCount <= 0) {
      Log.error('Error::exceed retryCount but not reach endpoint');
    }
    return extra.retryCount > 0 &&
        err.type == DioErrorType.other &&
        err.error != null &&
        err.error is SocketException;
  }
}

class RetryOptions {
  final int retryCount;
  final Duration sleepTime;
  static const extraKey = "cache_retry_request";

  const RetryOptions(
      {this.retryCount = 3, this.sleepTime = const Duration(seconds: 1)})
      : assert(retryCount != null),
        assert(sleepTime != null);

  factory RetryOptions.noRetry() {
    return RetryOptions(
      retryCount: 0,
    );
  }

  factory RetryOptions.fromExtra(RequestOptions request) {
    return request.extra[extraKey];
  }

  RetryOptions copyWith({
    int? retryCount,
    Duration? sleepTime,
  }) =>
      RetryOptions(
        retryCount: retryCount ?? this.retryCount,
        sleepTime: sleepTime ?? this.sleepTime,
      );

  Map<String, dynamic> toExtra() {
    return {
      extraKey: this,
    };
  }

  Options toOptions() {
    return Options(extra: this.toExtra());
  }

// ++ merge is no longer supported
  Options? mergeIn(Options options) {
    //   return options.merge(
    //       extra: <String, dynamic>{}
    //         ..addAll(options.extra ?? {})
    //         ..addAll(this.toExtra()));
  }
}
