import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/config/env.dart';
import '../entities/cart_item.dart';

@injectable
class CartRepository {
  late final Dio _dio;

  CartRepository() {
    _dio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
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

  Future<List<CartItem>> getCartItems() async {
    try {
      debugPrint('正在获取购物车列表...');
      final response = await _dio.get('/api/${Env.apiVersion}/cart');
      debugPrint('获取购物车列表响应: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> cartJson = response.data as List<dynamic>;
        final items = cartJson
            .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('成功解析 ${items.length} 个购物车项目');
        return items;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '获取购物车列表失败：${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Error Type: ${e.type}');
      debugPrint('Error Response: ${e.response?.data}');

      if (e.type == DioExceptionType.connectionTimeout) {
        throw '连接超时，请检查网络连接';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw '服务器响应超时，请稍后重试';
      } else if (e.response?.statusCode == 404) {
        throw '未找到购物车数据';
      } else {
        throw '无法连接到服务器，请检查服务器是否正常运行: ${e.message}';
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw '获取购物车列表时发生错误：$e';
    }
  }

  Future<void> addToCart({
    required String productCode,
    Map<String, dynamic>? selectedAttrs,
  }) async {
    try {
      debugPrint('正在添加商品到购物车: $productCode');
      final response = await _dio.post(
        '/api/${Env.apiVersion}/cart',
        data: {
          'productCode': productCode,
          'selectedAttrs': selectedAttrs,
        },
      );
      debugPrint('添加商品到购物车响应: ${response.data}');

      if (response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '添加商品到购物车失败：${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw '连接超时，请检查网络连接';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw '服务器响应超时，请稍后重试';
      } else {
        throw '添加商品到购物车失败: ${e.message}';
      }
    }
  }

  Future<void> updateQuantity({
    required String cartId,
    required int quantity,
  }) async {
    try {
      debugPrint('正在更新购物车商品数量: $cartId, 数量: $quantity');
      final response = await _dio.put(
        '/api/${Env.apiVersion}/cart/$cartId',
        data: {'quantity': quantity},
      );
      debugPrint('更新购物车商品数量响应: ${response.data}');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '更新购物车商品数量失败：${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw '连接超时，请检查网络连接';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw '服务器响应超时，请稍后重试';
      } else {
        throw '更新购物车商品数量失败: ${e.message}';
      }
    }
  }

  Future<void> removeItem({required String cartId}) async {
    try {
      debugPrint('正在删除购物车商品: $cartId');
      final response = await _dio.delete('/api/${Env.apiVersion}/cart/$cartId');
      debugPrint('删除购物车商品响应: ${response.data}');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '删除购物车商品失败：${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw '连接超时，请检查网络连接';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw '服务器响应超时，请稍后重试';
      } else {
        throw '删除购物车商品失败: ${e.message}';
      }
    }
  }

  Future<void> checkout({required List<String> cartIds}) async {
    try {
      debugPrint('正在结算购物车: $cartIds');
      final response = await _dio.post(
        '/api/${Env.apiVersion}/orders',
        data: {'cartIds': cartIds},
      );
      debugPrint('结算购物车响应: ${response.data}');

      if (response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '结算购物车失败：${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw '连接超时，请检查网络连接';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw '服务器响应超时，请稍后重试';
      } else {
        throw '结算购物车失败: ${e.message}';
      }
    }
  }
}
