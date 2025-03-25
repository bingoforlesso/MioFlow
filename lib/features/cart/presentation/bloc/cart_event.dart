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
