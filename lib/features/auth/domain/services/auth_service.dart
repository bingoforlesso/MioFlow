import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/env.dart';

@lazySingleton
class AuthService {
  late final Dio _dio;

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: Env.connectionTimeout,
      receiveTimeout: Env.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('Request URL: ${options.uri}');
          debugPrint('Request Method: ${options.method}');
          debugPrint('Request Headers: ${options.headers}');
          debugPrint('Request Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('Response Status: ${response.statusCode}');
          debugPrint('Response Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('Error: ${error.message}');
          debugPrint('Error Type: ${error.type}');
          debugPrint('Error Response: ${error.response?.data}');
          return handler.next(error);
        },
      ));
    }
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      debugPrint('正在尝试登录...');
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );

      debugPrint('登录响应状态码: ${response.statusCode}');
      debugPrint('登录响应内容: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        // 保存认证信息到本地存储
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['data']['token']);
        await prefs.setString('phone', phone);
        await prefs.setString('userId', data['data']['user']['id']);
        return data['data'];
      } else if (response.statusCode == 401) {
        throw Exception('用户名或密码错误');
      } else if (response.statusCode == 404) {
        throw Exception('服务器连接失败，请检查后端服务是否运行');
      } else {
        final error = response.data;
        throw Exception(error['error']['message'] ?? '登录失败');
      }
    } catch (e) {
      debugPrint('登录错误: $e');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw '手机号未注册或密码错误';
        } else if (e.response?.statusCode == 404) {
          throw '服务器连接失败，请检查网络连接';
        } else if (e.type == DioExceptionType.connectionTimeout) {
          throw '连接超时，请检查网络连接';
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw '服务器响应超时，请稍后重试';
        } else {
          final error = e.response?.data;
          throw error?['error']?['message'] ?? '登录失败，请稍后重试';
        }
      }
      throw '网络错误，请稍后重试';
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
        await _dio.post('/api/v1/auth/logout');
      }
    } catch (e) {
      debugPrint('登出接口调用失败: $e');
    } finally {
      // 无论后端调用是否成功，都清除本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('phone');
      await prefs.remove('userId');
    }
  }

  Future<bool> isPhoneRegistered(String phone) async {
    try {
      final response = await _dio.get('/api/v1/auth/check-phone/$phone');
      return response.data['exists'] ?? false;
    } catch (e) {
      debugPrint('检查手机号错误: $e');
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('未登录');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('/api/v1/auth/me');

      debugPrint('获取用户信息响应状态码: ${response.statusCode}');
      debugPrint('获取用户信息响应内容: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 401) {
        throw Exception('登录已过期，请重新登录');
      } else if (response.statusCode == 404) {
        throw Exception('服务器连接失败，请检查后端服务是否运行');
      } else {
        throw Exception('获取用户信息失败');
      }
    } catch (e) {
      debugPrint('获取用户信息错误: $e');
      rethrow;
    }
  }
}
