import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class DealerService {
  final String baseUrl;

  DealerService() : baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';

  Future<List<Map<String, dynamic>>> getDealers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('未登录');
      }

      final url = Uri.parse('$baseUrl/api/dealers');
      debugPrint('正在获取经销商列表: $url');

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

      debugPrint('获取经销商列表响应状态码: ${response.statusCode}');
      debugPrint('获取经销商列表响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']['dealers']);
      } else {
        throw Exception('获取经销商列表失败');
      }
    } catch (e) {
      debugPrint('获取经销商列表错误: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDealerDetails(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('未登录');
      }

      final url = Uri.parse('$baseUrl/api/dealers/$id');
      debugPrint('正在获取经销商详情: $url');

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

      debugPrint('获取经销商详情响应状态码: ${response.statusCode}');
      debugPrint('获取经销商详情响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['dealer'];
      } else {
        throw Exception('获取经销商详情失败');
      }
    } catch (e) {
      debugPrint('获取经销商详情错误: $e');
      rethrow;
    }
  }
}
