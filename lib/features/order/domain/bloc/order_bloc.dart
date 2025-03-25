import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart' hide Order;
import '../entities/order.dart';
import '../services/order_service.dart';

abstract class OrderEvent {}

class LoadOrdersEvent extends OrderEvent {}

class LoadOrderDetailsEvent extends OrderEvent {
  final String orderId;

  LoadOrderDetailsEvent({required this.orderId});
}

abstract class OrderState {}

class OrderInitialState extends OrderState {}

class OrderLoadingState extends OrderState {}

class OrderLoadedState extends OrderState {
  final List<Order> orders;

  OrderLoadedState({required this.orders});
}

class OrderDetailsLoadedState extends OrderState {
  final Order order;

  OrderDetailsLoadedState({required this.order});
}

class OrderErrorState extends OrderState {
  final String message;

  OrderErrorState({required this.message});
}

@injectable
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderService _orderService;

  OrderBloc(this._orderService) : super(OrderInitialState()) {
    on<OrderEvent>((event, emit) async {
      if (event is LoadOrdersEvent) {
        await _onLoadOrders(emit);
      } else if (event is LoadOrderDetailsEvent) {
        await _onLoadOrderDetails(event.orderId, emit);
      }
    });
  }

  Future<void> _onLoadOrders(Emitter<OrderState> emit) async {
    try {
      emit(OrderLoadingState());
      final orders = await _orderService.getOrders();
      emit(OrderLoadedState(orders: orders));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoadOrderDetails(
      String orderId, Emitter<OrderState> emit) async {
    try {
      emit(OrderLoadingState());
      final order = await _orderService.getOrderDetails(orderId);
      emit(OrderDetailsLoadedState(order: order));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }
}
