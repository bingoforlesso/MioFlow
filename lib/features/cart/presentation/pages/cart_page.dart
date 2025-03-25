import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/cart_item_widget.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('购物车'),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartInitialState) {
            return const Center(child: Text('购物车为空'));
          } else if (state is CartLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoadedState) {
            if (state.items.isEmpty) {
              return const Center(child: Text('购物车为空'));
            }
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return CartItemWidget(
                  item: item,
                  onQuantityChanged: (quantity) {
                    context.read<CartBloc>().add(
                          UpdateQuantityEvent(
                            cartId: item.id,
                            quantity: quantity,
                          ),
                        );
                  },
                  onRemove: () {
                    context.read<CartBloc>().add(
                          RemoveItemEvent(cartId: item.id),
                        );
                  },
                );
              },
            );
          } else if (state is CartErrorState) {
            return Center(child: Text(state.message));
          } else if (state is CartCheckoutSuccessState) {
            return const Center(child: Text('下单成功'));
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoadedState) {
            if (state.items.isEmpty) return const SizedBox.shrink();
            final total = state.items.fold<double>(
              0,
              (sum, item) => sum + (item.price * item.quantity),
            );
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      '总计: ¥${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CartBloc>().add(
                              CheckoutEvent(
                                cartIds: state.items.map((e) => e.id).toList(),
                              ),
                            );
                      },
                      child: const Text('结算'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
