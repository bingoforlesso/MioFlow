import 'package:injectable/injectable.dart';
import '../entities/product.dart';
import '../models/filter_group.dart';
import '../models/filter_option.dart';
import '../models/filter_state.dart';

@injectable
class FilterService {
  /// 从产品列表中提取筛选选项
  List<FilterGroup> extractFilterGroups(List<Product> products) {
    final Map<FilterAttribute, Map<String, int>> optionCounts = {};

    // 统计每个属性的选项出现次数
    for (final product in products) {
      _countAttribute(
          optionCounts, FilterAttribute.specification, product.specification);
      _countAttribute(optionCounts, FilterAttribute.degree, product.degree);
      _countAttribute(optionCounts, FilterAttribute.material, product.material);
      _countAttribute(optionCounts, FilterAttribute.brand, product.brand);
      _countAttribute(optionCounts, FilterAttribute.model, product.model);
      _countAttribute(
          optionCounts, FilterAttribute.productType, product.productType);
      _countAttribute(optionCounts, FilterAttribute.name, product.name);
      _countAttribute(optionCounts, FilterAttribute.color, product.color);
      _countAttribute(optionCounts, FilterAttribute.length, product.length);
      _countAttribute(optionCounts, FilterAttribute.pressure, product.pressure);
      _countAttribute(optionCounts, FilterAttribute.weight, product.weight);
      _countAttribute(
          optionCounts, FilterAttribute.outputBrand, product.outputBrand);
      _countAttribute(optionCounts, FilterAttribute.wattage, product.wattage);
      _countAttribute(
          optionCounts, FilterAttribute.usageType, product.usageType);
      _countAttribute(optionCounts, FilterAttribute.subType, product.subType);
    }

    // 转换为FilterGroup列表
    return optionCounts.entries.map((entry) {
      final options = entry.value.entries
          .where((e) => e.key.isNotEmpty) // 过滤掉空值
          .map((e) => FilterOption(
                filterAttribute: entry.key,
                value: e.key,
                count: e.value,
              ))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count)); // 按数量降序排序

      return FilterGroup(
        attribute: entry.key,
        options: options,
      );
    }).toList()
      ..sort((a, b) => a.attribute.displayName
          .compareTo(b.attribute.displayName)); // 按显示名称排序
  }

  /// 应用筛选条件
  List<Product> applyFilters(
    List<Product> products,
    Map<FilterAttribute, Set<String>> selectedFilters,
  ) {
    if (selectedFilters.isEmpty) return products;

    return products.where((product) {
      return selectedFilters.entries.every((entry) {
        final attribute = entry.key;
        final selectedValues = entry.value;
        if (selectedValues.isEmpty) return true;

        final productValue = _getProductValue(product, attribute);
        return selectedValues.contains(productValue);
      });
    }).toList();
  }

  /// 统计属性值出现次数
  void _countAttribute(
    Map<FilterAttribute, Map<String, int>> counts,
    FilterAttribute attribute,
    String? value,
  ) {
    if (value == null || value.isEmpty) return;
    counts.putIfAbsent(attribute, () => {});
    counts[attribute]![value] = (counts[attribute]![value] ?? 0) + 1;
  }

  /// 获取产品的属性值
  String _getProductValue(Product product, FilterAttribute attribute) {
    switch (attribute) {
      case FilterAttribute.specification:
        return product.specification ?? '';
      case FilterAttribute.degree:
        return product.degree ?? '';
      case FilterAttribute.material:
        return product.material ?? '';
      case FilterAttribute.brand:
        return product.brand ?? '';
      case FilterAttribute.model:
        return product.model ?? '';
      case FilterAttribute.productType:
        return product.productType ?? '';
      case FilterAttribute.name:
        return product.name;
      case FilterAttribute.color:
        return product.color ?? '';
      case FilterAttribute.length:
        return product.length ?? '';
      case FilterAttribute.pressure:
        return product.pressure ?? '';
      case FilterAttribute.weight:
        return product.weight ?? '';
      case FilterAttribute.outputBrand:
        return product.outputBrand ?? '';
      case FilterAttribute.wattage:
        return product.wattage ?? '';
      case FilterAttribute.usageType:
        return product.usageType ?? '';
      case FilterAttribute.subType:
        return product.subType ?? '';
    }
  }
}
