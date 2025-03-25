import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AddressService {
  final String baseUrl;

  AddressService() : baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';

  Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('未登录');
      }

      final url = Uri.parse('$baseUrl/api/addresses');
      debugPrint('正在获取地址列表: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('连接超时，请检查网络');
        },
      );

      debugPrint('获取地址列表响应状态码: ${response.statusCode}');
      debugPrint('获取地址列表响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']['addresses']);
      } else {
        throw Exception('获取地址列表失败');
      }
    } catch (e) {
      debugPrint('获取地址列表错误: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createAddress({
    required String name,
    required String phone,
    required String province,
    required String city,
    required String district,
    required String detail,
    required bool isDefault,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('未登录');
      }

      final url = Uri.parse('$baseUrl/api/addresses');
      debugPrint('正在创建地址: $url');

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'phone': phone,
          'province': province,
          'city': city,
          'district': district,
          'detail': detail,
          'is_default': isDefault,
        }),
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('连接超时，请检查网络');
        },
      );

      debugPrint('创建地址响应状态码: ${response.statusCode}');
      debugPrint('创建地址响应内容: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data']['address'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? '创建地址失败');
      }
    } catch (e) {
      debugPrint('创建地址错误: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateAddress({
    required String id,
    required String name,
    required String phone,
    required String province,
    required String city,
    required String district,
    required String detail,
    required bool isDefault,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('未登录');
      }

      final url = Uri.parse('$baseUrl/api/addresses/$id');
      debugPrint('正在更新地址: $url');

      final response = await http
          .put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'phone': phone,
          'province': province,
          'city': city,
          'district': district,
          'detail': detail,
          'is_default': isDefault,
        }),
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('连接超时，请检查网络');
        },
      );

      debugPrint('更新地址响应状态码: ${response.statusCode}');
      debugPrint('更新地址响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['address'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? '更新地址失败');
      }
    } catch (e) {
      debugPrint('更新地址错误: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('未登录');
      }

      final url = Uri.parse('$baseUrl/api/addresses/$id');
      debugPrint('正在删除地址: $url');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('连接超时，请检查网络');
        },
      );

      debugPrint('删除地址响应状态码: ${response.statusCode}');
      debugPrint('删除地址响应内容: ${response.body}');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? '删除地址失败');
      }
    } catch (e) {
      debugPrint('删除地址错误: $e');
      rethrow;
    }
  }

  Future<void> setDefaultAddress(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('未登录');
      }

      final url = Uri.parse('$baseUrl/api/addresses/$id/default');
      debugPrint('正在设置默认地址: $url');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('连接超时，请检查网络');
        },
      );

      debugPrint('设置默认地址响应状态码: ${response.statusCode}');
      debugPrint('设置默认地址响应内容: ${response.body}');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? '设置默认地址失败');
      }
    } catch (e) {
      debugPrint('设置默认地址错误: $e');
      rethrow;
    }
  }
}
