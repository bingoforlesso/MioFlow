import 'package:freezed_annotation/freezed_annotation.dart';

class Product {
  final String id;
  final String name;
  final String? code;
  final Map<String, List<String>>? attributes;
  final double? price;
  final String? imageUrl;
  final String? description;
  final int? stock;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.code,
    this.attributes,
    this.price,
    this.imageUrl,
    this.description,
    this.stock,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
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
    final attributes = <String, List<String>>{
      '规格': [json['specification']?.toString() ?? ''],
      '度数': [json['degree']?.toString() ?? ''],
      '材质': [json['material']?.toString() ?? ''],
      '品牌': [json['brand']?.toString() ?? ''],
      '型号': [json['model']?.toString() ?? ''],
      '产品类型': [json['product_type']?.toString() ?? ''],
      '颜色': [json['color']?.toString() ?? ''],
      '长度': [json['length']?.toString() ?? ''],
      '压力': [json['pressure']?.toString() ?? ''],
      '重量': [json['weight']?.toString() ?? ''],
      '输出品牌': [json['output_brand']?.toString() ?? ''],
      '功率': [json['wattage']?.toString() ?? ''],
      '使用类型': [json['usage_type']?.toString() ?? ''],
      '子类型': [json['sub_type']?.toString() ?? '']
    };

    // 移除空值
    attributes.removeWhere((key, value) => value.first.isEmpty);

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '未命名产品',
      code: json['code']?.toString(),
      attributes: attributes,
      price: price,
      imageUrl: json['image']?.toString(),
      description: json['description']?.toString(),
      stock: json['stock'] is num ? (json['stock'] as num).toInt() : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
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

  // 获取特定属性的值
  List<String>? getAttribute(String key) => attributes?[key];

  // 辅助方法，获取常用属性
  String? get specification => getAttribute('规格')?.firstOrNull;
  String? get degree => getAttribute('度数')?.firstOrNull;
  String? get material => getAttribute('材质')?.firstOrNull;
  String? get brand => getAttribute('品牌')?.firstOrNull;
  String? get model => getAttribute('型号')?.firstOrNull;
  String? get productType => getAttribute('产品类型')?.firstOrNull;
  String? get color => getAttribute('颜色')?.firstOrNull;
  String? get length => getAttribute('长度')?.firstOrNull;
  String? get pressure => getAttribute('压力')?.firstOrNull;
  String? get weight => getAttribute('重量')?.firstOrNull;
  String? get outputBrand => getAttribute('输出品牌')?.firstOrNull;
  String? get wattage => getAttribute('功率')?.firstOrNull;
  String? get usageType => getAttribute('使用类型')?.firstOrNull;
  String? get subType => getAttribute('子类型')?.firstOrNull;
}
