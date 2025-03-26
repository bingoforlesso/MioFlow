import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../config/env.dart';

@singleton
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add logging interceptor
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      debugPrint('GET Request: $path');
      debugPrint('Query Parameters: $queryParameters');
      final response = await _dio.get(path, queryParameters: queryParameters);
      debugPrint('Response: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('连接超时，请检查网络连接');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('接收数据超时，请稍后重试');
      } else if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? '请求失败');
      } else {
        throw Exception('网络请求失败: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      throw Exception('发生未知错误: $e');
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      debugPrint('POST Request: $path');
      debugPrint('Request Data: $data');
      final response = await _dio.post(path, data: data);
      debugPrint('Response: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('连接超时，请检查网络连接');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('接收数据超时，请稍后重试');
      } else if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? '请求失败');
      } else {
        throw Exception('网络请求失败: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      throw Exception('发生未知错误: $e');
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      debugPrint('PUT Request: $path');
      debugPrint('Request Data: $data');
      final response = await _dio.put(path, data: data);
      debugPrint('Response: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('连接超时，请检查网络连接');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('接收数据超时，请稍后重试');
      } else if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? '请求失败');
      } else {
        throw Exception('网络请求失败: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      throw Exception('发生未知错误: $e');
    }
  }

  Future<Response> delete(String path) async {
    try {
      debugPrint('DELETE Request: $path');
      final response = await _dio.delete(path);
      debugPrint('Response: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('连接超时，请检查网络连接');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('接收数据超时，请稍后重试');
      } else if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? '请求失败');
      } else {
        throw Exception('网络请求失败: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      throw Exception('发生未知错误: $e');
    }
  }
}
