import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String code,
    required String name,
    required String brand,
    required String material_code,
    String? image_url,
    String? output_brand,
    String? product_name,
    String? model,
    String? specification,
    String? color,
    String? length,
    String? weight,
    String? wattage,
    String? pressure,
    String? degree,
    String? material,
    double? price,
    String? product_type,
    String? usage_type,
    String? sub_type,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
