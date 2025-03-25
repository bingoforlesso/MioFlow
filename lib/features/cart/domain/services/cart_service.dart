import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

@injectable
class CartService {
  final CartRepository _repository;

  CartService(this._repository);

  Future<List<CartItem>> getCartItems() async {
    return await _repository.getCartItems();
  }

  Future<void> addToCart({
    required String productCode,
    Map<String, dynamic>? selectedAttrs,
  }) async {
    await _repository.addToCart(
      productCode: productCode,
      selectedAttrs: selectedAttrs,
    );
  }

  Future<void> updateQuantity({
    required String cartId,
    required int quantity,
  }) async {
    await _repository.updateQuantity(
      cartId: cartId,
      quantity: quantity,
    );
  }

  Future<void> removeItem({required String cartId}) async {
    await _repository.removeItem(cartId: cartId);
  }

  Future<void> checkout({required List<String> cartIds}) async {
    await _repository.checkout(cartIds: cartIds);
  }
}
