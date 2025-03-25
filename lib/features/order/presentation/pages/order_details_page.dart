import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../domain/bloc/order_bloc.dart';
import '../../domain/entities/order.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderNo;

  const OrderDetailsPage({
    super.key,
    required this.orderNo,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<OrderBloc>()..add(LoadOrderDetailsEvent(orderId: orderNo)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('订单详情'),
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderInitialState) {
              return const Center(child: Text('加载中...'));
            } else if (state is OrderLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderDetailsLoadedState) {
              final order = state.order;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderInfo(order),
                    const SizedBox(height: 16),
                    const Text(
                      '订单商品',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildOrderItems(order.items),
                    const SizedBox(height: 16),
                    _buildTotalAmount(order),
                  ],
                ),
              );
            } else if (state is OrderErrorState) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildOrderInfo(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '订单号: ${order.orderNo}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '创建时间: ${_formatDateTime(order.createTime)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '状态: ${_getStatusText(order.status)}',
              style: TextStyle(
                color: _getStatusColor(order.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(List<OrderItem> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '商品编码: ${item.productCode}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (item.selectedAttrs?['color'] != null) ...[
                        const SizedBox(height: 4),
                        Text('颜色: ${item.selectedAttrs!['color']}'),
                      ],
                      if (item.selectedAttrs?['length'] != null) ...[
                        const SizedBox(height: 4),
                        Text('长度: ${item.selectedAttrs!['length']}'),
                      ],
                      const SizedBox(height: 4),
                      Text('数量: ${item.quantity}'),
                    ],
                  ),
                ),
                Text(
                  '¥${item.price}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalAmount(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '订单总金额',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '¥${order.totalAmount}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '待确认';
      case 'confirmed':
        return '已确认';
      case 'delivered':
        return '已发货';
      case 'completed':
        return '已完成';
      default:
        return '未知状态';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'delivered':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
