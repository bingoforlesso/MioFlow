part of 'product_list_bloc.dart';

@freezed
class ProductListState with _$ProductListState {
  const factory ProductListState.initial() = _Initial;
  const factory ProductListState.loading() = _Loading;
  const factory ProductListState.loaded({
    required List<Product> products,
    required List<Product> filteredProducts,
    required List<FilterGroup> filterGroups,
    required Map<FilterAttribute, String> selectedFilters,
    required List<FilterOption> favoriteFilters,
    @Default(false) bool isLoading,
    String? error,
  }) = _Loaded;
  const factory ProductListState.error({
    required String message,
  }) = _Error;
}
