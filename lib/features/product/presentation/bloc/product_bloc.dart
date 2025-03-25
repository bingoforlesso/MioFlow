import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mio_ding/features/product/domain/entities/product.dart';
import 'package:mio_ding/features/product/domain/repositories/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';
part 'product_bloc.freezed.dart';

@freezed
class ProductEvent with _$ProductEvent {
  const factory ProductEvent.loadProducts() = _LoadProducts;

  const factory ProductEvent.searchProducts(String query) = _SearchProducts;

  const factory ProductEvent.applyFilters({
    required Map<String, List<String>> filters,
  }) = _ApplyFilters;

  const factory ProductEvent.clearFilters() = _ClearFilters;
}

@freezed
class ProductState with _$ProductState {
  const factory ProductState.initial() = _Initial;
  const factory ProductState.loading() = _Loading;
  const factory ProductState.loaded({
    required List<Product> products,
  }) = _Loaded;
  const factory ProductState.error({
    required String message,
  }) = _Error;
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc(this._productRepository) : super(const ProductState.initial()) {
    on<_LoadProducts>(_onLoadProducts);
    on<_SearchProducts>(_onSearchProducts);
    on<_ApplyFilters>(_onApplyFilters);
    on<_ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadProducts(
    _LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductState.loading());
      final products = await _productRepository.getAllProducts();
      emit(ProductState.loaded(products: products));
    } catch (e) {
      emit(ProductState.error(message: e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    _SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductState.loading());
      final products = await _productRepository.searchProducts(event.query);
      emit(ProductState.loaded(products: products));
    } catch (e) {
      emit(ProductState.error(message: e.toString()));
    }
  }

  Future<void> _onApplyFilters(
    _ApplyFilters event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductState.loading());
      final products = await _productRepository.filterProducts(event.filters);
      emit(ProductState.loaded(products: products));
    } catch (e) {
      emit(ProductState.error(message: e.toString()));
    }
  }

  Future<void> _onClearFilters(
    _ClearFilters event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductState.initial());
  }
}
