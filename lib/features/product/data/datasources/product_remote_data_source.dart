import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductDetails(String productId);
  Future<List<ProductModel>> searchProducts({
    required String query,
    int page = 1,
    int pageSize = 20,
  });
}

@Injectable(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/products');
      if (response.data?['success'] == true) {
        final List<dynamic> productsJson = response.data?['data'] ?? [];
        return productsJson
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(
        message: response.data?['message'] ?? '获取产品列表失败',
      );
    } catch (e) {
      throw ServerException(
        message: e is DioException ? e.message ?? '网络错误' : e.toString(),
      );
    }
  }

  @override
  Future<ProductModel> getProductDetails(String productId) async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('/products/$productId');
      if (response.data?['success'] == true) {
        final productJson = response.data?['data'];
        if (productJson != null) {
          return ProductModel.fromJson(productJson as Map<String, dynamic>);
        }
      }
      throw ServerException(
        message: response.data?['message'] ?? '获取产品详情失败',
      );
    } catch (e) {
      throw ServerException(
        message: e is DioException ? e.message ?? '网络错误' : e.toString(),
      );
    }
  }

  @override
  Future<List<ProductModel>> searchProducts({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      print('搜索产品: query=$query, page=$page, pageSize=$pageSize');
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/products/search',
        data: {
          'query': query,
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data?['success'] == true) {
        final List<dynamic> productsJson = response.data?['data'] ?? [];
        print('找到 ${productsJson.length} 个产品');
        print('产品详情: $productsJson');
        return productsJson
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: response.data?['message'] ?? '搜索产品失败',
      );
    } catch (e) {
      print('搜索产品时出错: $e');
      throw ServerException(
        message: e is DioException ? e.message ?? '网络错误' : e.toString(),
      );
    }
  }
}
