import 'package:dio/dio.dart';

class APIResponse {
  final bool success;
  final dynamic data;
  final String? message;
  final String code;

  APIResponse(
      {required this.success, this.data, this.message, required this.code});

  factory APIResponse.fromDioResponse(Response dio) {
    Map res = dio.data;
    return APIResponse(
        success: res['success'],
        data: res['payload'],
        message: res['message'],
        code: res['code']);
  }

  @override
  String toString() {
    return '[== status: $success, data: $data, message: $message, code: $code ==]';
  }
}
