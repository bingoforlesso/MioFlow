import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<List<Product>> searchProducts(String query);
  Future<Product> getProductById(String id);
  Future<List<Product>> filterProducts(Map<String, List<String>> filters);
}
