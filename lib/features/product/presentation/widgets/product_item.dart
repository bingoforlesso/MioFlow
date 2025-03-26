import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductItem({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 产品基本信息
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (product.specification != null) ...[
                const SizedBox(height: 8),
                Text(
                  product.specification!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 8),
              // 价格信息
              Text(
                '¥${product.price?.toStringAsFixed(2) ?? "暂无价格"}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              // 产品详细信息
              if (product.brand != null) ...[
                Text('品牌: ${product.brand}'),
              ],
              if (product.material != null) ...[
                Text('材质: ${product.material}'),
              ],
              if (product.color != null) ...[
                Text('颜色: ${product.color}'),
              ],
              if (product.productType != null) ...[
                Text('类型: ${product.productType}'),
              ],
              if (product.usageType != null) ...[
                Text('用途: ${product.usageType}'),
              ],
              // 规格信息
              if (product.length != null ||
                  product.weight != null ||
                  product.wattage != null ||
                  product.pressure != null ||
                  product.degree != null) ...[
                const SizedBox(height: 8),
                const Text('规格参数:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (product.length != null) Text('长度: ${product.length}'),
                if (product.weight != null) Text('重量: ${product.weight}'),
                if (product.wattage != null) Text('功率: ${product.wattage}'),
                if (product.pressure != null) Text('压力: ${product.pressure}'),
                if (product.degree != null) Text('角度: ${product.degree}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
