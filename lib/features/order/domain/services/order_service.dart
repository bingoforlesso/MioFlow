import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/env.dart';
import '../entities/order.dart';

@lazySingleton
class OrderService {
  late final Dio _dio;

  OrderService() {
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
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
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

  Future<List<Order>> getOrders() async {
    try {
      debugPrint('正在获取订单列表...');
      final response = await _dio.get('/api/${Env.apiVersion}/orders');
      debugPrint('获取订单列表响应: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = response.data['data'] ?? [];
        final orders = ordersJson
            .map((json) => Order(
                  id: json['order_no'],
                  orderNo: json['order_no'],
                  totalAmount: (json['total_amount'] as num).toDouble(),
                  status: json['status'],
                  createTime: DateTime.parse(json['created_at']),
                  items: const [], // 订单列表不包含详细商品信息
                ))
            .toList();
        debugPrint('成功解析 ${orders.length} 个订单');
        return orders;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '获取订单列表失败：${response.statusCode}',
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
      } else if (e.response?.statusCode == 401) {
        throw '未登录或登录已过期';
      } else if (e.response?.statusCode == 404) {
        throw '未找到订单数据';
      } else {
        throw '无法连接到服务器，请检查服务器是否正常运行: ${e.message}';
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw '获取订单列表时发生错误：$e';
    }
  }

  Future<Order> getOrderDetails(String orderNo) async {
    try {
      debugPrint('正在获取订单详情: $orderNo');
      final response = await _dio.get('/api/${Env.apiVersion}/orders/$orderNo');
      debugPrint('获取订单详情响应: ${response.data}');

      if (response.statusCode == 200) {
        final orderData = response.data['data']['order'] ?? {};
        final itemsData = response.data['data']['items'] ?? [];

        final order = Order(
          id: orderData['order_no'],
          orderNo: orderData['order_no'],
          totalAmount: (orderData['total_amount'] as num).toDouble(),
          status: orderData['status'],
          createTime: DateTime.parse(orderData['created_at']),
          items: (itemsData as List)
              .map((item) => OrderItem(
                    id: item['id'],
                    productCode: item['product_code'],
                    productName: item['product_name'],
                    productImage: item['product_image'],
                    price: (item['unit_price'] as num).toDouble(),
                    quantity: item['quantity'],
                    selectedAttrs: {
                      'color': item['selected_color'],
                      'length': item['selected_length'],
                    },
                  ))
              .toList(),
        );
        debugPrint('成功解析订单详情: ${order.orderNo}');
        return order;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '获取订单详情失败：${response.statusCode}',
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
      } else if (e.response?.statusCode == 401) {
        throw '未登录或登录已过期';
      } else if (e.response?.statusCode == 404) {
        throw '未找到订单详情';
      } else {
        throw '无法连接到服务器，请检查服务器是否正常运行: ${e.message}';
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw '获取订单详情时发生错误：$e';
    }
  }

  Future<Order> createOrder({
    required String dealerId,
    required String addressId,
    required List<String> itemIds,
  }) async {
    try {
      debugPrint('正在创建订单...');
      final response = await _dio.post(
        '/api/${Env.apiVersion}/orders',
        data: {
          'dealer_id': dealerId,
          'address_id': addressId,
          'item_ids': itemIds,
        },
      );
      debugPrint('创建订单响应: ${response.data}');

      if (response.statusCode == 201) {
        final orderData = response.data['data']['order'] ?? {};
        final order = Order(
          id: orderData['order_no'],
          orderNo: orderData['order_no'],
          totalAmount: (orderData['total_amount'] as num).toDouble(),
          status: orderData['status'],
          createTime: DateTime.parse(orderData['created_at']),
          items: const [], // 创建订单时不返回详细商品信息
        );
        debugPrint('成功创建订单: ${order.orderNo}');
        return order;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '创建订单失败：${response.statusCode}',
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
      } else if (e.response?.statusCode == 401) {
        throw '未登录或登录已过期';
      } else {
        throw '创建订单失败: ${e.message}';
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw '创建订单时发生错误：$e';
    }
  }
}
