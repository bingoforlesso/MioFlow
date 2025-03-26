import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (product.specification != null) ...[
              Text(
                product.specification!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],
            // 价格信息
            Text(
              '价格: ¥${product.price?.toStringAsFixed(2) ?? "暂无价格"}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
            // 产品详细信息
            const Text(
              '产品信息',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoSection('品牌', product.brand),
            _buildInfoSection('材质', product.material),
            _buildInfoSection('颜色', product.color),
            _buildInfoSection('产品类型', product.productType),
            _buildInfoSection('用途', product.usageType),
            _buildInfoSection('子类型', product.subType),
            const SizedBox(height: 24),
            // 规格参数
            if (product.length != null ||
                product.weight != null ||
                product.wattage != null ||
                product.pressure != null ||
                product.degree != null) ...[
              const Text(
                '规格参数',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoSection('长度', product.length),
              _buildInfoSection('重量', product.weight),
              _buildInfoSection('功率', product.wattage),
              _buildInfoSection('压力', product.pressure),
              _buildInfoSection('角度', product.degree),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
