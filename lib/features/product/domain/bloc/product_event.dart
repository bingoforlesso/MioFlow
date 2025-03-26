part of 'product_bloc.dart';

@freezed
class ProductEvent with _$ProductEvent {
  const factory ProductEvent.loadProducts() = _LoadProducts;
  const factory ProductEvent.loadProductDetails({
    required String productId,
  }) = _LoadProductDetails;
  const factory ProductEvent.searchProducts({
    required String query,
  }) = _SearchProducts;
  const factory ProductEvent.retryLastOperation() = _RetryLastOperation;
}
