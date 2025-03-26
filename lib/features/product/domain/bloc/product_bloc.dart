import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../repositories/product_repository.dart';
import '../entities/product.dart';

part 'product_bloc.freezed.dart';
part 'product_state.dart';
part 'product_event.dart';

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc(this._productRepository) : super(const ProductState.initial()) {
    on<_LoadProducts>((event, emit) async {
      emit(const ProductState.loading());
      try {
        final products = await _productRepository.getProducts();
        if (products.isEmpty) {
          emit(const ProductState.loaded(products: []));
        } else {
          emit(ProductState.loaded(products: products));
        }
      } catch (e) {
        emit(ProductState.error(message: e.toString()));
      }
    });

    on<_LoadProductDetails>((event, emit) async {
      emit(const ProductState.loading());
      try {
        final product =
            await _productRepository.getProductDetails(event.productId);
        if (product == null) {
          emit(const ProductState.loaded(products: []));
        } else {
          emit(ProductState.loaded(products: [product]));
        }
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
        emit(ProductState.loaded(products: products));
      } catch (e) {
        emit(ProductState.error(message: e.toString()));
      }
    });

    on<_RetryLastOperation>((event, emit) async {
      final currentState = state;
      if (currentState is _Error) {
        emit(const ProductState.loading());
        try {
          final products = await _productRepository.getProducts();
          if (products.isEmpty) {
            emit(const ProductState.loaded(products: []));
          } else {
            emit(ProductState.loaded(products: products));
          }
        } catch (e) {
          emit(ProductState.error(message: e.toString()));
        }
      }
    });
  }
}
