class Order {
  final String id;
  final String orderNo;
  final double totalAmount;
  final String status;
  final DateTime createTime;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNo,
    required this.totalAmount,
    required this.status,
    required this.createTime,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNo: json['orderNo'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'totalAmount': totalAmount,
      'status': status,
      'createTime': createTime.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final String id;
  final String productCode;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final Map<String, dynamic>? selectedAttrs;

  OrderItem({
    required this.id,
    required this.productCode,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.selectedAttrs,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      productCode: json['productCode'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      selectedAttrs: json['selectedAttrs'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productCode': productCode,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'selectedAttrs': selectedAttrs,
    };
  }
}
