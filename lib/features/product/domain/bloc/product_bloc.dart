import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../services/product_service.dart';
import '../entities/product.dart';

part 'product_bloc.freezed.dart';
part 'product_event.dart';
part 'product_state.dart';

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService _productService;

  ProductBloc(this._productService) : super(const ProductState.initial()) {
    on<ProductEvent>((event, emit) async {
      await event.map(
        loadProducts: (e) async {
          try {
            emit(const ProductState.loading());
            final products = await _productService.getProducts();
            emit(ProductState.loaded(products: products));
          } catch (error) {
            emit(ProductState.error(message: error.toString()));
          }
        },
        loadProductDetails: (e) async {
          try {
            emit(const ProductState.loading());
            final product =
                await _productService.getProductDetails(e.productCode);
            if (product != null) {
              emit(ProductState.loaded(products: [product]));
            } else {
              emit(const ProductState.error(message: '商品不存在'));
            }
          } catch (error) {
            emit(ProductState.error(message: error.toString()));
          }
        },
        searchProducts: (e) async {
          try {
            emit(const ProductState.loading());
            final products = await _productService.searchProducts(e.query);
            emit(ProductState.loaded(products: products));
          } catch (error) {
            emit(ProductState.error(message: error.toString()));
          }
        },
      );
    });
  }
}
