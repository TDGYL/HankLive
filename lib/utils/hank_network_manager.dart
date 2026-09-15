import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// HankApiResponse: 网络请求响应实体
/// 封装接口返回的 code、data、message
class HankApiResponse<T> {
  /// 业务状态码（0表示成功）
  final int? code;

  /// 响应数据体
  final T? data;

  /// 响应消息描述
  final String? message;

  HankApiResponse({this.code, this.data, this.message});

  /// 是否请求成功
  bool get isSuccess => code == 0;
}

/// HankNetworkManager: 网络请求管理类
/// 基于 Dio 封装的单例网络请求工具，含拦截器日志、Token管理、GET/POST请求
class HankNetworkManager {
  /// 单例实例
  static final HankNetworkManager _instance = HankNetworkManager._internal();

  /// Dio 实例
  late Dio _dio;

  /// 工厂构造，返回单例
  factory HankNetworkManager() {
    return _instance;
  }

  /// 私有构造，初始化 Dio 配置和拦截器
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

    // 添加请求/响应/错误拦截器
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

  /// 设置 Authorization Token
  void setAuthToken(String token) {
    _dio.options.headers['authorization'] = token;
  }

  /// 清除 Authorization Token
  void clearAuthToken() {
    _dio.options.headers.remove('authorization');
  }

  /// GET 请求
  /// [path] 接口路径
  /// [queryParameters] 查询参数
  /// 返回 HankApiResponse 封装结果
  Future<HankApiResponse<dynamic>> getRequest(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _parseResponse(response);
    } catch (e) {
      return _parseError(e);
    }
  }

  /// POST 请求
  /// [path] 接口路径
  /// [data] 请求体数据
  /// 返回 HankApiResponse 封装结果
  Future<HankApiResponse<dynamic>> postRequest(String path,
      {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _parseResponse(response);
    } catch (e) {
      return _parseError(e);
    }
  }

  /// 解析响应数据
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

  /// 解析异常信息
  HankApiResponse<dynamic> _parseError(dynamic error) {
    String msg = 'Unknown Error';
    if (error is DioException) {
      msg = error.message ?? 'Dio Error';
    }
    return HankApiResponse(code: -1, message: msg);
  }
}
