import 'dart:io';
import 'package:dio/dio.dart';

import '../logger.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final RetryOptions options;
  RetryInterceptor(
    this.dio,
    {
    this.options = const RetryOptions(),
  });

  @override
  Future onError(DioError err) async {
    var extra = RetryOptions.fromExtra(err.request) ?? this.options;

    if (_shouldRetry(err, extra)) {
      await Future.delayed(extra.sleepTime);
      Log.warning('Retry::${err.request.path}');
      extra = extra.copyWith(retryCount: extra.retryCount - 1);
      err.request.extra = err.request.extra..addAll(extra.toExtra());

      return await this.dio.request(
            err.request.path,
            cancelToken: err.request.cancelToken,
            data: err.request.data,
            onReceiveProgress: err.request.onReceiveProgress,
            onSendProgress: err.request.onSendProgress,
            queryParameters: err.request.queryParameters,
            options: err.request,
          );
    }
    return super.onError(err);
  }

  bool _shouldRetry(DioError err, RetryOptions extra) {
    if (extra.retryCount <= 0) {
      Log.error('Error::exceed retryCount but not reach endpoint');
    }
    return extra.retryCount > 0 &&
        err.type == DioErrorType.DEFAULT &&
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
    int retryCount,
    Duration sleepTime,
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

  Options mergeIn(Options options) {
    return options.merge(
        extra: <String, dynamic>{}
          ..addAll(options.extra ?? {})
          ..addAll(this.toExtra()));
  }
}
