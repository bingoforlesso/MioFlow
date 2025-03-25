part of 'product_bloc.dart';

@freezed
class ProductEvent with _$ProductEvent {
  const factory ProductEvent.loadProducts() = _LoadProducts;
  const factory ProductEvent.loadProductDetails(String productCode) = _LoadProductDetails;
  const factory ProductEvent.searchProducts(String query) = _SearchProducts;
}
