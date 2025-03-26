import 'dart:async';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mio_ding/features/product/domain/entities/product.dart';
import 'package:mio_ding/features/product/domain/repositories/product_repository.dart';

@injectable
class ProductSearchService {
  final Dio _dio;
  final ProductRepository _productRepository;

  @injectable
  ProductSearchService(this._dio, this._productRepository);

  Future<List<Map<String, dynamic>>> searchProductsByParameters(
      Map<String, dynamic> parameters) async {
    try {
      final response = await _dio.post('/products/search', data: parameters);
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('搜索产品时出错: $e');
      return [];
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      return await _productRepository.searchProducts(
        query: query,
        page: 1,
        pageSize: 20,
      );
    } catch (e) {
      print('搜索产品时出错: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('获取产品详情时出错: $e');
      return null;
    }
  }
}
