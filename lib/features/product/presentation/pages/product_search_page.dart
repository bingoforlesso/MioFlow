import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/models/filter_group.dart';
import '../../domain/models/filter_option.dart';
import '../bloc/product_bloc.dart';
import '../widgets/filter_panel.dart';
import '../widgets/product_grid.dart';
import '../widgets/selected_filters.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  late TextEditingController _searchController;
  final Map<FilterAttribute, Set<String>> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<ProductBloc>().add(ProductEvent.searchProducts(query: query));
  }

  void _handleFilterOptionSelected(
      FilterAttribute attribute, String value, bool isSelected) {
    setState(() {
      _selectedFilters.putIfAbsent(attribute, () => {});
      if (!isSelected) {
        _selectedFilters[attribute]!.remove(value);
        if (_selectedFilters[attribute]!.isEmpty) {
          _selectedFilters.remove(attribute);
        }
      } else {
        _selectedFilters[attribute]!.add(value);
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilters.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索产品'),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return state.when(
            initial: () => _buildInitialState(),
            loading: () => _buildLoadingState(),
            loaded: (products) => products.isEmpty
                ? const Center(child: Text('暂无数据'))
                : _buildLoadedState(products),
            error: (message) => _buildErrorState(message),
          );
        },
      ),
      bottomNavigationBar: _buildSearchBar(),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Text('请输入搜索关键词'),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('错误: $message'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context
                  .read<ProductBloc>()
                  .add(const ProductEvent.loadProducts());
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '输入产品名称、型号或规格',
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final query = _searchController.text.trim();
              if (query.isNotEmpty) {
                _onSearch(query);
              }
            },
          ),
        ),
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            _onSearch(query);
          }
        },
      ),
    );
  }

  Widget _buildLoadedState(List<Product> products) {
    return Column(
      children: [
        // 顶部已选筛选条件
        SelectedFilters(
          selectedFilters: _selectedFilters,
          onRemove: (attribute, value) =>
              _handleFilterOptionSelected(attribute, value, false),
          onClearAll: _clearAllFilters,
        ),
        Expanded(
          child: Row(
            children: [
              // 左侧筛选面板
              FilterPanel(
                filterGroups: _generateFilterGroups(products),
                selectedFilters: _selectedFilters,
                onFilterSelected: _handleFilterOptionSelected,
                onClearFilters: _clearAllFilters,
                onFavoriteToggle: (_) {}, // 暂时不实现收藏功能
                favoriteFilters: const {}, // 暂时不使用收藏功能
              ),
              // 右侧商品列表
              Expanded(
                child: ProductGrid(
                  products: _applyFilters(products),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<FilterGroup> _generateFilterGroups(List<Product> products) {
    // 生成筛选组
    final filterGroups = <FilterGroup>[];
    final attributeValues = <FilterAttribute, Set<String>>{};

    // 收集所有属性值
    for (final product in products) {
      for (final attribute in FilterAttribute.values) {
        final value = _getProductAttribute(product, attribute);
        if (value != null && value.isNotEmpty) {
          attributeValues.putIfAbsent(attribute, () => {}).add(value);
        }
      }
    }

    // 生成筛选组
    for (final attribute in FilterAttribute.values) {
      final values = attributeValues[attribute];
      if (values != null && values.isNotEmpty) {
        filterGroups.add(
          FilterGroup(
            attribute: attribute,
            options: values
                .map((value) => FilterOption(
                      filterAttribute: attribute,
                      value: value,
                      count: products
                          .where((p) =>
                              _getProductAttribute(p, attribute) == value)
                          .length,
                    ))
                .toList()
              ..sort((a, b) => b.count.compareTo(a.count)),
          ),
        );
      }
    }

    return filterGroups;
  }

  String? _getProductAttribute(Product product, FilterAttribute attribute) {
    switch (attribute) {
      case FilterAttribute.brand:
        return product.brand;
      case FilterAttribute.material:
        return product.material;
      case FilterAttribute.outputBrand:
        return product.outputBrand;
      case FilterAttribute.name:
        return product.name;
      case FilterAttribute.model:
        return product.model;
      case FilterAttribute.specification:
        return product.specification;
      case FilterAttribute.color:
        return product.color;
      case FilterAttribute.length:
        return product.length;
      case FilterAttribute.weight:
        return product.weight;
      case FilterAttribute.wattage:
        return product.wattage;
      case FilterAttribute.pressure:
        return product.pressure;
      case FilterAttribute.degree:
        return product.degree;
      case FilterAttribute.productType:
        return product.productType;
      case FilterAttribute.usageType:
        return product.usageType;
      case FilterAttribute.subType:
        return product.subType;
    }
  }

  List<Product> _applyFilters(List<Product> products) {
    if (_selectedFilters.isEmpty) {
      return products;
    }

    return products.where((product) {
      return _selectedFilters.entries.every((entry) {
        final attribute = entry.key;
        final values = entry.value;
        final productValue = _getProductAttribute(product, attribute);
        return productValue != null && values.contains(productValue);
      });
    }).toList();
  }
}
