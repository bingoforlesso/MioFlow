import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/services/order_service.dart';
import 'order_event.dart';
import 'order_state.dart';

@injectable
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderService _orderService;

  OrderBloc({required OrderService orderService})
      : _orderService = orderService,
        super(OrderInitialState()) {
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
    String orderId,
    Emitter<OrderState> emit,
  ) async {
    try {
      emit(OrderLoadingState());
      final order = await _orderService.getOrderDetails(orderId);
      emit(OrderLoadedState(orders: [order]));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }
}
