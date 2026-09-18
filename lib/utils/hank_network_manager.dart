import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// HankApiResponse: network response entity
/// wrapAPIBack code、data、message
class HankApiResponse<T> {
  /// businessstatuscode（0means success）
  final int? code;

  /// responseDatabody
  final T? data;

  /// response message
  final String? message;

  HankApiResponse({this.code, this.data, this.message});

  /// whetherRequest successful
  bool get isSuccess => code == 0;
}

/// HankNetworkManager: networkrequestmanagetype
/// based on Dio wrapsingletonnetworkrequestutility，with interceptor logging、Tokenmanage、GET/POSTrequest
class HankNetworkManager {
  /// singleton instance
  static final HankNetworkManager _instance = HankNetworkManager._internal();

  /// Dio instance
  late Dio _dio;

  /// factoryconstructor，Backsingleton
  factory HankNetworkManager() {
    return _instance;
  }

  /// private constructor，init Dio configandinterceptor
  HankNetworkManager._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.livespeeds.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-platform': 'IOS',
        'Accept-Language': 'en-US',
        'x-version': '6.0.0'
      },
    ));

    // addrequest/response/error interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint(
            '\n==================== HankNetwork Request ====================');
        debugPrint('Method: ${options.method}');
        debugPrint('URL: ${options.baseUrl}${options.path}');
        if (options.queryParameters.isNotEmpty) {
          debugPrint('QueryParameters: ${options.queryParameters}');
        }
        debugPrint('Headers: ${options.headers}');
        if (options.data != null) {
          debugPrint('Data: ${options.data}');
        }
        debugPrint(
            '=============================================================\n');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
            '\n==================== HankNetwork Response ===================');
        debugPrint(
            'URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
        debugPrint('StatusCode: ${response.statusCode}');
        debugPrint('Data: ${response.data}');
        debugPrint(
            '=============================================================\n');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint(
            '\n==================== HankNetwork Error ======================');
        debugPrint('URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}');
        debugPrint('Error: ${e.message}');
        if (e.response != null) {
          debugPrint('StatusCode: ${e.response?.statusCode}');
          debugPrint('Data: ${e.response?.data}');
        }
        debugPrint(
            '=============================================================\n');
        return handler.next(e);
      },
    ));
  }

  /// Settings Authorization Token
  void setAuthToken(String token) {
    _dio.options.headers['authorization'] = token;
  }

  /// clear Authorization Token
  void clearAuthToken() {
    _dio.options.headers.remove('authorization');
  }

  /// GET request
  /// [path] APIpath
  /// [queryParameters] searchqueryparamcount
  /// Back HankApiResponse wrapresults
  Future<HankApiResponse<dynamic>> getRequest(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _parseResponse(response);
    } catch (e) {
      return _parseError(e);
    }
  }

  /// POST request
  /// [path] APIpath
  /// [data] request bodyData
  /// Back HankApiResponse wrapresults
  Future<HankApiResponse<dynamic>> postRequest(String path,
      {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _parseResponse(response);
    } catch (e) {
      return _parseError(e);
    }
  }

  /// parse responseData
  HankApiResponse<dynamic> _parseResponse(Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      return HankApiResponse(
        code: data['code'] as int?,
        data: data['data'],
        message: data['message'] as String?,
      );
    } else {
      return HankApiResponse(
        code: response.statusCode,
        message: 'Network Error: ${response.statusCode}',
      );
    }
  }

  /// parseerrorinfo
  HankApiResponse<dynamic> _parseError(dynamic error) {
    String msg = 'Unknown Error';
    if (error is DioException) {
      msg = error.message ?? 'Dio Error';
    }
    return HankApiResponse(code: -1, message: msg);
  }
}
