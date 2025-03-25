import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/services/cart_service.dart';

// Events
abstract class CartEvent {}

class LoadCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final String productCode;
  final Map<String, dynamic>? selectedAttrs;

  AddToCartEvent({required this.productCode, this.selectedAttrs});
}

class UpdateQuantityEvent extends CartEvent {
  final String cartId;
  final int quantity;

  UpdateQuantityEvent({required this.cartId, required this.quantity});
}

class RemoveItemEvent extends CartEvent {
  final String cartId;

  RemoveItemEvent({required this.cartId});
}

class CheckoutEvent extends CartEvent {
  final List<String> cartIds;

  CheckoutEvent({required this.cartIds});
}

// States
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

@injectable
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService _cartService;

  CartBloc(this._cartService) : super(CartInitialState()) {
    on<CartEvent>((event, emit) async {
      if (event is LoadCartEvent) {
        await _onLoadCart(emit);
      } else if (event is AddToCartEvent) {
        await _onAddToCart(
          event.productCode,
          event.selectedAttrs,
          emit,
        );
      } else if (event is UpdateQuantityEvent) {
        await _onUpdateQuantity(
          event.cartId,
          event.quantity,
          emit,
        );
      } else if (event is RemoveItemEvent) {
        await _onRemoveItem(event.cartId, emit);
      } else if (event is CheckoutEvent) {
        await _onCheckout(event.cartIds, emit);
      }
    });
  }

  Future<void> _onLoadCart(Emitter<CartState> emit) async {
    try {
      emit(CartLoadingState());
      final items = await _cartService.getCartItems();
      emit(CartLoadedState(items: items));
    } catch (e) {
      emit(CartErrorState(message: e.toString()));
    }
  }

  Future<void> _onAddToCart(
    String productCode,
    Map<String, dynamic>? selectedAttrs,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartLoadingState());
      await _cartService.addToCart(
        productCode: productCode,
        selectedAttrs: selectedAttrs,
      );
      final items = await _cartService.getCartItems();
      emit(CartLoadedState(items: items));
    } catch (e) {
      emit(CartErrorState(message: e.toString()));
    }
  }

  Future<void> _onUpdateQuantity(
    String cartId,
    int quantity,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartLoadingState());
      await _cartService.updateQuantity(
        cartId: cartId,
        quantity: quantity,
      );
      final items = await _cartService.getCartItems();
      emit(CartLoadedState(items: items));
    } catch (e) {
      emit(CartErrorState(message: e.toString()));
    }
  }

  Future<void> _onRemoveItem(
    String cartId,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartLoadingState());
      await _cartService.removeItem(cartId: cartId);
      final items = await _cartService.getCartItems();
      emit(CartLoadedState(items: items));
    } catch (e) {
      emit(CartErrorState(message: e.toString()));
    }
  }

  Future<void> _onCheckout(
    List<String> cartIds,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartLoadingState());
      await _cartService.checkout(cartIds: cartIds);
      emit(CartCheckoutSuccessState(
          orderNo: 'ORDER-${DateTime.now().millisecondsSinceEpoch}'));
    } catch (e) {
      emit(CartErrorState(message: e.toString()));
    }
  }
}
