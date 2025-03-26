import 'package:injectable/injectable.dart';
import '../repositories/product_repository.dart';
import '../entities/product.dart';

@injectable
class SearchSuggestionService {
  final ProductRepository _productRepository;

  SearchSuggestionService(this._productRepository);

  Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final products = await _productRepository.searchProducts(
      query: query,
      page: 1,
      pageSize: 20,
    );
    return _extractSuggestions(products, query);
  }

  List<String> _extractSuggestions(List<Product> products, String query) {
    final suggestions = <String>{};

    for (final product in products) {
      if (product.name.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(product.name);
      }
      if (product.brand?.toLowerCase().contains(query.toLowerCase()) ?? false) {
        suggestions.add(product.brand!);
      }
      if (product.material?.toLowerCase().contains(query.toLowerCase()) ??
          false) {
        suggestions.add(product.material!);
      }
    }

    return suggestions.take(5).toList();
  }

  String getSearchHint(String query) {
    if (query.isEmpty) {
      return '输入产品名称、规格或属性进行搜索';
    }

    if (query.contains('弯头')) {
      return '可以输入角度（如：45度）和规格（如：DN110）';
    }

    if (query.contains('阀')) {
      return '可以输入类型（如：球阀、闸阀）和材质（如：铜、不锈钢）';
    }

    if (query.contains('管')) {
      return '可以输入材质（如：PVC-U、PPR）和用途（如：给水、排水）';
    }

    return '输入更多关键词以缩小搜索范围';
  }

  List<String> getPopularSearches() {
    return [
      'PVC-U给水管',
      'PPR热水管',
      '铜球阀',
      '45度弯头',
      '不锈钢闸阀',
      'DN110',
    ];
  }

  List<String> getRelatedSearches(String query) {
    if (query.contains('弯头')) {
      return [
        '45度弯头',
        '90度弯头',
        'PVC弯头',
        'PPR弯头',
        'DN110弯头',
      ];
    }

    if (query.contains('阀')) {
      return [
        '铜球阀',
        '不锈钢闸阀',
        'PPR球阀',
        'PVC蝶阀',
        '铸铁闸阀',
      ];
    }

    if (query.contains('管')) {
      return [
        'PVC-U给水管',
        'PPR热水管',
        'PE给水管',
        'PVC排水管',
        'HDPE排水管',
      ];
    }

    return [];
  }
}
