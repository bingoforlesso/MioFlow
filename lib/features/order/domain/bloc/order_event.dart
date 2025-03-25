part of 'order_bloc.dart';

@freezed
class OrderEvent with _$OrderEvent {
  const factory OrderEvent.loadOrders() = _LoadOrders;
  const factory OrderEvent.loadOrderDetails(String orderNo) = _LoadOrderDetails;
}
