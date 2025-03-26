import 'package:injectable/injectable.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';
import '../datasources/product_remote_data_source.dart';

@Injectable(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Product>> getProducts() async {
    return await _remoteDataSource.getProducts();
  }

  @override
  Future<Product?> getProductDetails(String productId) async {
    try {
      return await _remoteDataSource.getProductDetails(productId);
    } catch (e) {
      throw Exception('Failed to get product details: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _remoteDataSource.searchProducts(
      query: query,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<List<Product>> filterProducts(Map<String, dynamic> filters) async {
    final products = await getProducts();
    if (filters.isEmpty) return products;

    return products.where((product) {
      return filters.entries.every((filter) {
        final field = filter.key;
        final value = filter.value;
        if (value == null || value == '') return true;

        String? fieldValue;
        switch (field) {
          case 'id':
            fieldValue = product.id;
            break;
          case 'code':
            fieldValue = product.id;
            break;
          case 'name':
            fieldValue = product.name;
            break;
          case 'brand':
            fieldValue = product.brand;
            break;
          case 'material':
            fieldValue = product.material;
            break;
          case 'output_brand':
            fieldValue = product.outputBrand;
            break;
          case 'product_name':
            fieldValue = product.name;
            break;
          case 'model':
            fieldValue = product.model;
            break;
          case 'specification':
            fieldValue = product.specification;
            break;
          case 'color':
            fieldValue = product.color;
            break;
          case 'length':
            fieldValue = product.length;
            break;
          case 'weight':
            fieldValue = product.weight;
            break;
          case 'wattage':
            fieldValue = product.wattage;
            break;
          case 'pressure':
            fieldValue = product.pressure;
            break;
          case 'degree':
            fieldValue = product.degree;
            break;
          case 'product_type':
            fieldValue = product.productType;
            break;
          case 'usage_type':
            fieldValue = product.usageType;
            break;
          case 'sub_type':
            fieldValue = product.subType;
            break;
          default:
            return true;
        }

        if (fieldValue == null) return false;
        return fieldValue
            .toLowerCase()
            .contains(value.toString().toLowerCase());
      });
    }).toList();
  }
}
