import 'package:injectable/injectable.dart';
import '../repositories/product_repository.dart';
import '../entities/product.dart';

@injectable
class ProductMatcherService {
  final ProductRepository _productRepository;

  ProductMatcherService(this._productRepository);

  Future<List<Product>> searchProducts(String text) async {
    return await _productRepository.searchProducts(text);
  }

  Future<List<Product>> searchProductsByVoice(String voiceText) async {
    return await searchProducts(voiceText);
  }

  Future<List<Product>> searchProductsByImage(String imagePath) async {
    // TODO: Implement image search
    return [];
  }

  List<ProductSlot> _extractSlots(String text) {
    final slots = <ProductSlot>[];

    // 提取数量和规格组合（如：50个DN110）
    final quantitySpecRegex = RegExp(r'(\d+)\s*个\s*[Dd][Nn]\s*(\d+)');
    final quantitySpecMatches = quantitySpecRegex.allMatches(text);
    for (final match in quantitySpecMatches) {
      slots.add(ProductSlot('数量', '${match.group(1)}'));
      slots.add(ProductSlot('规格', 'DN${match.group(2)}'));
    }

    // 提取带前缀的类型（如 DA、GY）和角度
    final typeWithPrefixRegex = RegExp(r'\((DA|GY)\)?\s*(\d+)[°度]弯头');
    final typeWithPrefixMatches = typeWithPrefixRegex.allMatches(text);
    for (final match in typeWithPrefixMatches) {
      if (match.group(1) != null) {
        slots.add(ProductSlot('系列', match.group(1)!));
      }
      if (match.group(2) != null) {
        slots.add(ProductSlot('角度', '${match.group(2)}°'));
        slots.add(ProductSlot('类型', '弯头'));
      }
    }

    // 如果没有匹配到带前缀的类型，尝试匹配普通的角度和类型组合
    if (!slots.any((slot) => slot.key == '角度')) {
      final angleTypeRegex = RegExp(r'(\d+)[°度]弯头');
      final angleTypeMatches = angleTypeRegex.allMatches(text);
      for (final match in angleTypeMatches) {
        slots.add(ProductSlot('角度', '${match.group(1)}°'));
        slots.add(ProductSlot('类型', '弯头'));
      }
    }

    // 如果还没有匹配到规格，提取规格 (DN规格)
    if (!slots.any((slot) => slot.key == '规格')) {
      final dnSpecRegex = RegExp(r'[Dd][Nn]\s*(\d+)');
      final dnSpecMatches = dnSpecRegex.allMatches(text);
      for (final match in dnSpecMatches) {
        slots.add(ProductSlot('规格', 'DN${match.group(1)}'));
      }
    }

    // 提取材质和类型组合
    final materialWithTypeRegex =
        RegExp(r'(PVC-U|HDPE|PPR)(?:农业)?(?:专用|排水)?(?:管件)?');
    final materialWithTypeMatches = materialWithTypeRegex.allMatches(text);
    for (final match in materialWithTypeMatches) {
      slots.add(ProductSlot('材质', match.group(1)!));
    }

    // 提取用途
    final usageRegex = RegExp(r'(农业专用|农业排水|建筑排水)');
    final usageMatches = usageRegex.allMatches(text);
    for (final match in usageMatches) {
      slots.add(ProductSlot('用途', match.group(1)!));
    }

    // 提取规格 (常规尺寸)
    final specRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(mm|cm|m|inch)');
    final specMatches = specRegex.allMatches(text);
    for (final match in specMatches) {
      slots.add(ProductSlot('规格', '${match.group(1)}${match.group(2)}'));
    }

    // 提取颜色
    final colorRegex = RegExp(r'(白色|黑色|灰色|蓝色|红色|绿色|黄色|橙色|紫色|棕色)');
    final colorMatches = colorRegex.allMatches(text);
    for (final match in colorMatches) {
      slots.add(ProductSlot('颜色', match.group(1)!));
    }

    // 提取类型（如果还没有提取到）
    if (!slots.any((slot) => slot.key == '类型')) {
      final typeRegex = RegExp(r'(弯头|三通|直通|球阀|闸阀|截止阀)');
      final typeMatches = typeRegex.allMatches(text);
      for (final match in typeMatches) {
        slots.add(ProductSlot('类型', match.group(1)!));
      }
    }

    // 提取压力
    final pressureRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:MPa|mpa)');
    final pressureMatches = pressureRegex.allMatches(text);
    for (final match in pressureMatches) {
      slots.add(ProductSlot('压力', '${match.group(1)}MPa'));
    }

    // 提取长度
    final lengthRegex = RegExp(r'(\d+)\s*米');
    final lengthMatches = lengthRegex.allMatches(text);
    for (final match in lengthMatches) {
      slots.add(ProductSlot('长度', '${match.group(1)}米'));
    }

    // 提取数量（如果还没有提取到）
    if (!slots.any((slot) => slot.key == '数量')) {
      final quantityRegex = RegExp(r'(\d+)\s*(?:个|件|套|箱|包)');
      final quantityMatches = quantityRegex.allMatches(text);
      for (final match in quantityMatches) {
        slots.add(ProductSlot('数量', match.group(1)!));
      }
    }

    return slots;
  }
}

class ProductSlot {
  final String key;
  final String value;

  ProductSlot(this.key, this.value);

  @override
  String toString() => '$key: $value';
}
