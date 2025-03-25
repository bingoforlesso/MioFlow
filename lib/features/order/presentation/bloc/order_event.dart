abstract class OrderEvent {}

class LoadOrdersEvent extends OrderEvent {}

class LoadOrderDetailsEvent extends OrderEvent {
  final String orderId;

  LoadOrderDetailsEvent({required this.orderId});
}
