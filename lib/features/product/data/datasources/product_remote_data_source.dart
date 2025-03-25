import 'package:injectable/injectable.dart';
import 'package:mio_ding/core/services/api_service.dart';
import 'package:mio_ding/features/product/domain/entities/product.dart';

@injectable
class ProductRemoteDataSource {
  final ApiService _apiService;

  ProductRemoteDataSource(this._apiService);

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _apiService.post('/api/v1/product_info/search',
          data: {'query': query, 'params': []});
      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'] as List;
        return data.map((json) {
          final Map<String, dynamic> productJson = json as Map<String, dynamic>;
          return Product(
            id: productJson['id'] as String,
            code: productJson['code'] as String,
            name: productJson['name'] as String,
            brand: productJson['brand'] as String,
            material_code: productJson['material_code'] as String,
            output_brand: productJson['output_brand'] as String?,
            product_name: productJson['product_name'] as String?,
            model: productJson['model'] as String?,
            specification: productJson['specification'] as String?,
            color: productJson['color'] as String?,
            length: productJson['length'] as String?,
            weight: productJson['weight'] as String?,
            wattage: productJson['wattage'] as String?,
            pressure: productJson['pressure'] as String?,
            degree: productJson['degree'] as String?,
            material: productJson['material'] as String?,
            price: productJson['price'] != null
                ? (productJson['price'] as num).toDouble()
                : null,
            product_type: productJson['product_type'] as String?,
            usage_type: productJson['usage_type'] as String?,
            sub_type: productJson['sub_type'] as String?,
          );
        }).toList();
      } else {
        throw Exception('搜索产品失败: 返回数据格式错误');
      }
    } catch (e) {
      throw Exception('搜索产品失败: $e');
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final response = await _apiService.get('/api/product_info/$id');
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      return Product(
        id: data['id'] as String,
        code: data['code'] as String,
        name: data['name'] as String,
        brand: data['brand'] as String,
        material_code: data['material_code'] as String,
        output_brand: data['output_brand'] as String?,
        product_name: data['product_name'] as String?,
        model: data['model'] as String?,
        specification: data['specification'] as String?,
        color: data['color'] as String?,
        length: data['length'] as String?,
        weight: data['weight'] as String?,
        wattage: data['wattage'] as String?,
        pressure: data['pressure'] as String?,
        degree: data['degree'] as String?,
        material: data['material'] as String?,
        price: data['price'] != null ? (data['price'] as num).toDouble() : null,
        product_type: data['product_type'] as String?,
        usage_type: data['usage_type'] as String?,
        sub_type: data['sub_type'] as String?,
      );
    } catch (e) {
      throw Exception('获取产品详情失败: $e');
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _apiService.get('/api/product_info');
      final List<dynamic> data = response.data as List;
      return data.map((json) {
        final Map<String, dynamic> productJson = json as Map<String, dynamic>;
        return Product(
          id: productJson['id'] as String,
          code: productJson['code'] as String,
          name: productJson['name'] as String,
          brand: productJson['brand'] as String,
          material_code: productJson['material_code'] as String,
          output_brand: productJson['output_brand'] as String?,
          product_name: productJson['product_name'] as String?,
          model: productJson['model'] as String?,
          specification: productJson['specification'] as String?,
          color: productJson['color'] as String?,
          length: productJson['length'] as String?,
          weight: productJson['weight'] as String?,
          wattage: productJson['wattage'] as String?,
          pressure: productJson['pressure'] as String?,
          degree: productJson['degree'] as String?,
          material: productJson['material'] as String?,
          price: productJson['price'] != null
              ? (productJson['price'] as num).toDouble()
              : null,
          product_type: productJson['product_type'] as String?,
          usage_type: productJson['usage_type'] as String?,
          sub_type: productJson['sub_type'] as String?,
        );
      }).toList();
    } catch (e) {
      throw Exception('获取所有产品失败: $e');
    }
  }
}
