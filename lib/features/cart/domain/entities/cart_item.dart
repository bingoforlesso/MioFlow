class CartItem {
  final String id;
  final String productCode;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final Map<String, dynamic>? selectedAttrs;

  CartItem({
    required this.id,
    required this.productCode,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.selectedAttrs,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
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

  CartItem copyWith({
    String? id,
    String? productCode,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    Map<String, dynamic>? selectedAttrs,
  }) {
    return CartItem(
      id: id ?? this.id,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      selectedAttrs: selectedAttrs ?? this.selectedAttrs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productCode == other.productCode &&
          productName == other.productName &&
          productImage == other.productImage &&
          price == other.price &&
          quantity == other.quantity;

  @override
  int get hashCode =>
      id.hashCode ^
      productCode.hashCode ^
      productName.hashCode ^
      productImage.hashCode ^
      price.hashCode ^
      quantity.hashCode;
}
