import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

@singleton
class Database {
  late MySqlConnection _connection;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      // Web 平台使用 REST API 或其他替代方案
      print('Web 平台暂不支持直接数据库连接，请使用 REST API');
      _isInitialized = true;
      return;
    }

    final settings = ConnectionSettings(
      host: '127.0.0.1',
      port: 3306,
      user: 'root',
      password: 'Ac661978',
      db: 'mioflow',
    );

    try {
      _connection = await MySqlConnection.connect(settings);
      _isInitialized = true;
      print('数据库连接成功');
    } catch (e) {
      print('数据库连接失败: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> query(
      String sql, List<Object?> params) async {
    if (kIsWeb) {
      // Web 平台返回模拟数据
      return _getMockData(sql);
    }

    try {
      final results = await _connection.query(sql, params);
      return results.map((row) => row.fields).toList();
    } catch (e) {
      print('查询失败: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _getMockData(String sql) {
    // 根据 SQL 查询返回模拟数据
    if (sql.toLowerCase().contains('product_info')) {
      return [
        {
          'id': 1,
          'code': 'DA-001',
          'name': 'DA弯头',
          'description': '45度 DN110',
          'image': 'assets/images/products/da-001.jpg',
          'price': 15.99,
          'stock': 100,
          'attributes': {
            '角度': ['45度'],
            '规格': ['DN110'],
            '材质': ['PVC-U'],
          },
          'create_time': '2024-03-20 10:00:00',
          'update_time': '2024-03-20 10:00:00',
        },
        {
          'id': 2,
          'code': 'ST-001',
          'name': '四通管件',
          'description': 'DN110-75',
          'image': 'assets/images/products/st-001.jpg',
          'price': 25.99,
          'stock': 50,
          'attributes': {
            '规格': ['DN110', 'DN75'],
            '材质': ['HDPE'],
          },
          'create_time': '2024-03-20 10:00:00',
          'update_time': '2024-03-20 10:00:00',
        },
      ];
    }
    return [];
  }

  Future<void> close() async {
    if (!kIsWeb && _isInitialized) {
      await _connection.close();
    }
  }
}
