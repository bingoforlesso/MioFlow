import '../../domain/entities/order.dart';

abstract class OrderState {}

class OrderInitialState extends OrderState {}

class OrderLoadingState extends OrderState {}

class OrderLoadedState extends OrderState {
  final List<Order> orders;

  OrderLoadedState({required this.orders});
}

class OrderErrorState extends OrderState {
  final String message;

  OrderErrorState({required this.message});
}
