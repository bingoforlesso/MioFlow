import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_dialog.dart';

class ProductSearchResultsPage extends StatefulWidget {
  final String query;
  final List<Product> initialProducts;

  const ProductSearchResultsPage({
    super.key,
    required this.query,
    required this.initialProducts,
  });

  @override
  State<ProductSearchResultsPage> createState() =>
      _ProductSearchResultsPageState();
}

class _ProductSearchResultsPageState extends State<ProductSearchResultsPage> {
  late final ProductBloc _productBloc;
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 20;
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _productBloc = context.read<ProductBloc>();
    _productBloc.add(ProductEvent.searchProducts(query: widget.query));

    _scrollController.addListener(_onScroll);

    // 添加日志
    print('初始化搜索页面 - 关键词: ${widget.query}');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    print('加载更多产品 - 页码: $_currentPage');

    // TODO: 实现分页加载逻辑
    _productBloc.add(ProductEvent.loadMoreProducts(
      query: widget.query,
      page: _currentPage,
      pageSize: _pageSize,
    ));

    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('搜索结果: ${widget.query}'),
        actions: [
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              return state.maybeWhen(
                loaded: (products) {
                  print('显示产品数量: ${products.length}');
                  return IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterDialog(context, products),
                  );
                },
                orElse: () => const SizedBox(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('请输入搜索关键词')),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (products) {
              if (products.isEmpty) {
                return const Center(
                  child: Text('没有找到相关产品'),
                );
              }

              return GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(8),
                itemCount: products.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= products.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final product = products[index];
                  print(
                      '渲染产品: ${product.name} (${index + 1}/${products.length})');
                  return ProductCard(product: product);
                },
              );
            },
            error: (message) => Center(child: Text('错误: $message')),
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context, List<Product> products) {
    final attributes = _extractFilterableAttributes(products);
    showDialog(
      context: context,
      builder: (context) => ProductFilterDialog(
        attributes: attributes,
        activeFilters: const {},
        onApplyFilters: (filters) {
          print('应用筛选条件: $filters');
          _productBloc.add(ProductEvent.applyFilters(filters: filters));
        },
      ),
    );
  }

  Map<String, Set<String>> _extractFilterableAttributes(
      List<Product> products) {
    final attributes = <String, Set<String>>{
      'brand': {},
      'material': {},
      'color': {},
    };

    for (final product in products) {
      if (product.brand != null) attributes['brand']!.add(product.brand!);
      if (product.material != null)
        attributes['material']!.add(product.material!);
      if (product.color != null) attributes['color']!.add(product.color!);
    }

    return attributes;
  }
}
