import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/config/env.dart';
import '../entities/product.dart';

@injectable
class ProductService {
  late final Dio _dio;

  ProductService() {
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

  Future<List<Product>> searchProducts(String query) async {
    try {
      debugPrint('正在搜索商品...');
      final response = await _dio.post('/api/v1/products/search',
          data: {'query': query, 'params': []});
      debugPrint('搜索商品响应: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> productsJson =
              responseData['data'] as List<dynamic>;
          final products = productsJson
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
          debugPrint('成功解析 ${products.length} 个商品');
          return products;
        } else {
          throw '搜索商品失败：返回数据格式错误';
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '搜索商品失败：${response.statusCode}',
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
        throw '未找到商品数据';
      } else {
        throw '无法连接到服务器，请检查服务器是否正常运行: ${e.message}';
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw '搜索商品时发生错误：$e';
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      debugPrint('正在获取商品列表...');
      final response = await _dio.get('/api/v1/products');
      debugPrint('获取商品列表响应: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> productsJson =
            response.data['data'] as List<dynamic>;
        final products = productsJson
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('成功解析 ${products.length} 个商品');
        return products;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '获取商品列表失败：${response.statusCode}',
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
        throw '未找到商品数据';
      } else {
        throw '无法连接到服务器，请检查服务器是否正常运行: ${e.message}';
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw '获取商品列表时发生错误：$e';
    }
  }

  Future<Product?> getProductDetails(String code) async {
    try {
      debugPrint('正在获取商品详情: $code');
      final response = await _dio.get('/api/v1/products/code/$code');
      debugPrint('获取商品详情响应: ${response.data}');

      if (response.statusCode == 200) {
        return Product.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '获取商品详情失败：${response.statusCode}',
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
        throw '未找到商品数据';
      } else {
        throw '无法连接到服务器，请检查服务器是否正常运行: ${e.message}';
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw '获取商品详情时发生错误：$e';
    }
  }
}
