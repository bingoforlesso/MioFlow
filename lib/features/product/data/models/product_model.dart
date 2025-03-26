import 'package:mioflow/features/product/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.code,
    super.attributes,
    super.price,
    super.imageUrl,
    super.description,
    super.stock,
    super.createdAt,
    super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // 处理价格字段
    double? price;
    if (json['price'] != null) {
      if (json['price'] is String) {
        price = double.tryParse(json['price']);
      } else if (json['price'] is num) {
        price = (json['price'] as num).toDouble();
      }
    }

    // 构建属性映射
    final attributes = <String, List<String>>{};
    
    void addAttribute(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        attributes[key] = [value];
      }
    }

    addAttribute('规格', json['specification']?.toString());
    addAttribute('材质', json['material']?.toString());
    addAttribute('品牌', json['brand']?.toString());
    addAttribute('型号', json['model']?.toString());
    addAttribute('颜色', json['color']?.toString());
    addAttribute('长度', json['length']?.toString());
    addAttribute('重量', json['weight']?.toString());
    addAttribute('功率', json['wattage']?.toString());
    addAttribute('压力', json['pressure']?.toString());
    addAttribute('角度', json['degree']?.toString());
    addAttribute('产品类型', json['product_type']?.toString());
    addAttribute('使用类型', json['usage_type']?.toString());
    addAttribute('子类型', json['sub_type']?.toString());
    addAttribute('输出品牌', json['output_brand']?.toString());

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '未命名产品',
      code: json['code']?.toString(),
      attributes: attributes.isEmpty ? null : attributes,
      price: price,
      imageUrl: json['image']?.toString(),
      description: json['description']?.toString(),
      stock: json['stock'] is num ? (json['stock'] as num).toInt() : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'attributes': attributes,
      'price': price,
      'image': imageUrl,
      'description': description,
      'stock': stock,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}