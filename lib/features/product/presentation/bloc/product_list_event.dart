part of 'product_list_bloc.dart';

@freezed
class ProductListEvent with _$ProductListEvent {
  const factory ProductListEvent.started() = _Started;
  const factory ProductListEvent.filterSelected({
    required FilterAttribute attribute,
    required String value,
    required bool isSelected,
  }) = _FilterSelected;
  const factory ProductListEvent.clearFilters() = _ClearFilters;
  const factory ProductListEvent.toggleFavorite({
    required FilterOption option,
  }) = _ToggleFavorite;
  const factory ProductListEvent.search({
    required String query,
  }) = _Search;
}
