import '../../domain/entities/cart_item.dart';

abstract class CartState {}

class CartInitialState extends CartState {}

class CartLoadingState extends CartState {}

class CartLoadedState extends CartState {
  final List<CartItem> items;

  CartLoadedState({required this.items});
}

class CartErrorState extends CartState {
  final String message;

  CartErrorState({required this.message});
}

class CartCheckoutSuccessState extends CartState {
  final String orderNo;

  CartCheckoutSuccessState({required this.orderNo});
}
