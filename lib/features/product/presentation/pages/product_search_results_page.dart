import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_item.dart';
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

  @override
  void initState() {
    super.initState();
    _productBloc = context.read<ProductBloc>();
    _productBloc.add(ProductEvent.searchProducts(widget.query));
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

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductItem(
                    product: product,
                    onTap: () {
                      // TODO: Navigate to product details
                    },
                  );
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
      if (product.material != null) {
        attributes['material']!.add(product.material!);
      }
      if (product.color != null) {
        attributes['color']!.add(product.color!);
      }
    }

    return attributes;
  }
}
