part of 'product_bloc.dart';

@freezed
class ProductEvent with _$ProductEvent {
  const factory ProductEvent.loadProducts() = _LoadProducts;
  const factory ProductEvent.searchProducts({
    required String query,
  }) = _SearchProducts;
  const factory ProductEvent.loadMoreProducts({
    required String query,
    required int page,
    required int pageSize,
  }) = _LoadMoreProducts;
  const factory ProductEvent.applyFilters({
    required Map<String, List<String>> filters,
  }) = _ApplyFilters;
  const factory ProductEvent.clearFilters() = _ClearFilters;
}
