part of 'order_bloc.dart';

@freezed
class OrderState with _$OrderState {
  const factory OrderState.initial() = _Initial;
  const factory OrderState.loading() = _Loading;
  const factory OrderState.loaded(List<Map<String, dynamic>> orders) = _Loaded;
  const factory OrderState.orderDetailsLoaded(
      Map<String, dynamic> orderDetails) = _OrderDetailsLoaded;
  const factory OrderState.error(String message) = _Error;
}
