import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/product.dart';
import '../../domain/models/filter_group.dart';
import '../../domain/models/filter_option.dart';
import '../../domain/repositories/product_repository.dart';

part 'product_list_bloc.freezed.dart';
part 'product_list_event.dart';
part 'product_list_state.dart';

@injectable
class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final ProductRepository _productRepository;

  ProductListBloc(this._productRepository)
      : super(const ProductListState.initial()) {
    on<_Started>(_onStarted);
    on<_FilterSelected>(_onFilterSelected);
    on<_ClearFilters>(_onClearFilters);
    on<_ToggleFavorite>(_onToggleFavorite);
    on<_Search>(_onSearch);
  }

  Future<void> _onStarted(
    _Started event,
    Emitter<ProductListState> emit,
  ) async {
    emit(const ProductListState.loading());
    try {
      final products = await _productRepository.getProducts();
      final filterGroups = _generateFilterGroups(products);
      emit(ProductListState.loaded(
        products: products,
        filteredProducts: products,
        filterGroups: filterGroups,
        selectedFilters: {},
        favoriteFilters: [],
      ));
    } catch (e) {
      emit(ProductListState.error(message: e.toString()));
    }
  }

  Future<void> _onFilterSelected(
    _FilterSelected event,
    Emitter<ProductListState> emit,
  ) async {
    final currentState = state;
    if (currentState is _Loaded) {
      final selectedFilters =
          Map<FilterAttribute, String>.from(currentState.selectedFilters);
      if (event.isSelected) {
        selectedFilters[event.attribute] = event.value;
      } else {
        selectedFilters.remove(event.attribute);
      }

      final filteredProducts =
          _applyFilters(currentState.products, selectedFilters);
      emit(currentState.copyWith(
        selectedFilters: selectedFilters,
        filteredProducts: filteredProducts,
      ));
    }
  }

  Future<void> _onClearFilters(
    _ClearFilters event,
    Emitter<ProductListState> emit,
  ) async {
    final currentState = state;
    if (currentState is _Loaded) {
      emit(currentState.copyWith(
        selectedFilters: {},
        filteredProducts: currentState.products,
      ));
    }
  }

  Future<void> _onToggleFavorite(
    _ToggleFavorite event,
    Emitter<ProductListState> emit,
  ) async {
    final currentState = state;
    if (currentState is _Loaded) {
      final favoriteFilters =
          List<FilterOption>.from(currentState.favoriteFilters);
      if (favoriteFilters.contains(event.option)) {
        favoriteFilters.remove(event.option);
      } else {
        favoriteFilters.add(event.option);
      }
      emit(currentState.copyWith(
        favoriteFilters: favoriteFilters,
      ));
    }
  }

  Future<void> _onSearch(
    _Search event,
    Emitter<ProductListState> emit,
  ) async {
    final currentState = state;
    if (currentState is _Loaded) {
      try {
        emit(currentState.copyWith(isLoading: true));
        final products = await _productRepository.searchProducts(
          query: event.query,
          page: 1,
          pageSize: 20,
        );
        final filterGroups = _generateFilterGroups(products);
        emit(currentState.copyWith(
          isLoading: false,
          products: products,
          filteredProducts: products,
          filterGroups: filterGroups,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      }
    }
  }

  List<FilterGroup> _generateFilterGroups(List<Product> products) {
    final filterGroups = <FilterGroup>[];
    final attributeValues = <FilterAttribute, Set<String>>{};

    for (final product in products) {
      if (product.attributes != null) {
        for (final entry in product.attributes!.entries) {
          final attributeName = entry.key;
          final attribute = FilterAttribute.values.firstWhere(
            (attr) => attr.name == attributeName,
            orElse: () => FilterAttribute.name,
          );
          final values = entry.value;
          if (values is List<String>) {
            for (final value in values) {
              if (value.isNotEmpty) {
                attributeValues
                    .putIfAbsent(attribute, () => <String>{})
                    .add(value);
              }
            }
          }
        }
      }
    }

    for (final entry in attributeValues.entries) {
      final options = entry.value
          .map((value) => FilterOption(
                filterAttribute: entry.key,
                value: value,
                count: products
                    .where((p) =>
                        p.attributes?[entry.key.name]?.contains(value) ?? false)
                    .length,
              ))
          .toList();
      if (options.isNotEmpty) {
        filterGroups.add(FilterGroup(
          attribute: entry.key,
          options: options,
        ));
      }
    }

    return filterGroups;
  }

  List<Product> _applyFilters(
    List<Product> products,
    Map<FilterAttribute, String> selectedFilters,
  ) {
    if (selectedFilters.isEmpty) {
      return products;
    }

    return products.where((product) {
      return selectedFilters.entries.every((filter) {
        final attributeKey = filter.key.name;
        final values = product.attributes?[attributeKey];
        return values?.contains(filter.value) ?? false;
      });
    }).toList();
  }
}
