import 'dart:async';
import 'package:injectable/injectable.dart';

@injectable
class CartService {
  final List<Map<String, dynamic>> _items = [];

  Future<void> addItem(Map<String, dynamic> item) async {
    // TODO: Implement actual cart logic with Redis
    _items.add(item);
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    return _items;
  }

  Future<void> removeItem(String productId) async {
    _items.removeWhere((item) => item['product_id'] == productId);
  }

  Future<void> clear() async {
    _items.clear();
  }

  Future<double> getTotal() async {
    double total = 0.0;
    for (var item in _items) {
      total += (item['price'] as double) * ((item['quantity'] as int?) ?? 1);
    }
    return total;
  }
}