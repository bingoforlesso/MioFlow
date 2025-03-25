import 'package:injectable/injectable.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

@Injectable(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      return await _remoteDataSource.searchProducts(query);
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      return await _remoteDataSource.getProductById(id);
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  @override
  Future<List<Product>> filterProducts(
      Map<String, List<String>> filters) async {
    final products = await _remoteDataSource.getAllProducts();
    return products.where((product) {
      return filters.entries.every((filter) {
        final key = filter.key.toLowerCase();
        final values = filter.value.map((v) => v.toLowerCase()).toList();

        String? fieldValue;
        switch (key) {
          case 'id':
            fieldValue = product.id;
            break;
          case 'code':
            fieldValue = product.code;
            break;
          case 'name':
          case '商品名称':
            fieldValue = product.name;
            break;
          case 'brand':
          case '品牌':
            fieldValue = product.brand;
            break;
          case 'material_code':
          case '材质代码':
            fieldValue = product.material_code;
            break;
          case 'output_brand':
          case '输出品牌':
            fieldValue = product.output_brand;
            break;
          case 'product_name':
          case '产品名称':
            fieldValue = product.product_name;
            break;
          case 'model':
          case '型号':
            fieldValue = product.model;
            break;
          case 'specification':
          case '规格':
            fieldValue = product.specification;
            break;
          case 'color':
          case '颜色':
            fieldValue = product.color;
            break;
          case 'length':
          case '长度':
            fieldValue = product.length;
            break;
          case 'weight':
          case '重量':
            fieldValue = product.weight;
            break;
          case 'wattage':
          case '瓦数':
            fieldValue = product.wattage;
            break;
          case 'pressure':
          case '压力':
            fieldValue = product.pressure;
            break;
          case 'degree':
          case '角度':
            fieldValue = product.degree;
            break;
          case 'material':
          case '材质':
            fieldValue = product.material;
            break;
          case 'product_type':
          case '产品类型':
            fieldValue = product.product_type;
            break;
          case 'usage_type':
          case '用途':
            fieldValue = product.usage_type;
            break;
          case 'sub_type':
          case '子类型':
            fieldValue = product.sub_type;
            break;
          case 'price':
          case '价格':
            fieldValue = product.price?.toString();
            break;
          default:
            return true;
        }

        if (fieldValue == null) {
          return values.contains('null') || values.isEmpty;
        }

        return values.any((value) => fieldValue!.toLowerCase().contains(value));
      });
    }).toList();
  }

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      return await _remoteDataSource.getAllProducts();
    } catch (e) {
      throw Exception('Failed to get all products: $e');
    }
  }
}
