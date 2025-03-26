import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';

part 'product_bloc.freezed.dart';
part 'product_state.dart';
part 'product_event.dart';

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;
  List<Product> _allProducts = [];

  ProductBloc(this._productRepository) : super(const ProductState.initial()) {
    on<_LoadProducts>((event, emit) async {
      emit(const ProductState.loading());
      try {
        final products = await _productRepository.getProducts();
        _allProducts = products;
        emit(ProductState.loaded(products: products));
      } catch (e) {
        emit(ProductState.error(message: e.toString()));
      }
    });

    on<_SearchProducts>((event, emit) async {
      emit(const ProductState.loading());
      try {
        final products = await _productRepository.searchProducts(
          query: event.query,
          page: 1,
          pageSize: 20,
        );
        _allProducts = products;
        emit(ProductState.loaded(products: products));
      } catch (e) {
        emit(ProductState.error(message: e.toString()));
      }
    });

    on<_LoadMoreProducts>((event, emit) async {
      final currentState = state;
      if (currentState is _Loaded) {
        try {
          final moreProducts = await _productRepository.searchProducts(
            query: event.query,
            page: event.page,
            pageSize: event.pageSize,
          );
          _allProducts.addAll(moreProducts);
          emit(ProductState.loaded(products: _allProducts));
        } catch (e) {
          emit(ProductState.error(message: e.toString()));
        }
      }
    });

    on<_ApplyFilters>((event, emit) async {
      final currentState = state;
      if (currentState is _Loaded) {
        final filteredProducts = _allProducts.where((product) {
          return event.filters.entries.every((entry) {
            final field = entry.key;
            final values = entry.value;
            final productValue = _getProductAttribute(product, field);
            return values.isEmpty ||
                (productValue != null && values.contains(productValue));
          });
        }).toList();
        emit(ProductState.loaded(products: filteredProducts));
      }
    });

    on<_ClearFilters>((event, emit) async {
      final currentState = state;
      if (currentState is _Loaded) {
        emit(ProductState.loaded(products: _allProducts));
      }
    });
  }

  String? _getProductAttribute(Product product, String field) {
    switch (field) {
      case 'brand':
        return product.brand;
      case 'material':
        return product.material;
      case 'outputBrand':
        return product.outputBrand;
      case 'name':
        return product.name;
      case 'model':
        return product.model;
      case 'specification':
        return product.specification;
      case 'color':
        return product.color;
      case 'length':
        return product.length;
      case 'weight':
        return product.weight;
      case 'wattage':
        return product.wattage;
      case 'pressure':
        return product.pressure;
      case 'degree':
        return product.degree;
      case 'productType':
        return product.productType;
      case 'usageType':
        return product.usageType;
      case 'subType':
        return product.subType;
      default:
        return null;
    }
  }
}
