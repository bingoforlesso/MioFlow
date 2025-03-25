import 'package:flutter/foundation.dart';

class OrderService extends ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      _orders = [
        {
          'id': '1',
          'orderNumber': 'ORD001',
          'date': DateTime.now().toString(),
          'status': 'Pending',
          'total': 299.99,
          'items': [
            {
              'name': 'Product 1',
              'quantity': 2,
              'price': 149.99,
            }
          ],
        },
        // Add more mock orders as needed
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      _orders.add(orderData);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      _orders.removeWhere((order) => order['id'] == orderId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}