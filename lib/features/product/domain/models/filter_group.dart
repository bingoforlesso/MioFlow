import 'package:freezed_annotation/freezed_annotation.dart';
import 'filter_option.dart';

part 'filter_group.freezed.dart';
part 'filter_group.g.dart';

@freezed
class FilterGroup with _$FilterGroup {
  const factory FilterGroup({
    required FilterAttribute attribute,
    required List<FilterOption> options,
  }) = _FilterGroup;

  factory FilterGroup.fromJson(Map<String, dynamic> json) =>
      _$FilterGroupFromJson(json);
}

enum FilterAttribute {
  @JsonValue('specification')
  specification('规格'),
  @JsonValue('degree')
  degree('度数'),
  @JsonValue('material')
  material('材质'),
  @JsonValue('brand')
  brand('品牌'),
  @JsonValue('model')
  model('型号'),
  @JsonValue('productType')
  productType('产品类型'),
  @JsonValue('name')
  name('名称'),
  @JsonValue('color')
  color('颜色'),
  @JsonValue('length')
  length('长度'),
  @JsonValue('pressure')
  pressure('压力'),
  @JsonValue('weight')
  weight('重量'),
  @JsonValue('outputBrand')
  outputBrand('输出品牌'),
  @JsonValue('wattage')
  wattage('功率'),
  @JsonValue('usageType')
  usageType('使用类型'),
  @JsonValue('subType')
  subType('子类型');

  final String displayName;
  const FilterAttribute(this.displayName);
}
