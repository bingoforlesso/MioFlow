import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductDetails(String productId);
  Future<List<Product>> searchProducts({
    required String query,
    int page = 1,
    int pageSize = 20,
  });
}
