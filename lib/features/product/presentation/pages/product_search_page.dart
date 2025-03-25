import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_filter_dialog.dart';
import '../widgets/product_item.dart';
import 'product_search_results_page.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => ProductFilterDialog(
        attributes: {
          'brand': {'品牌A', '品牌B', '品牌C'},
          'material': {'材料1', '材料2', '材料3'},
          'color': {'红色', '蓝色', '绿色'},
        },
        activeFilters: {},
        onApplyFilters: (Map<String, List<String>> filters) {
          context
              .read<ProductBloc>()
              .add(ProductEvent.applyFilters(filters: filters));
        },
      ),
    );
  }

  void _onSearchSubmitted(String value) {
    if (value.isNotEmpty) {
      context.read<ProductBloc>().add(ProductEvent.searchProducts(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('产品搜索'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '搜索产品...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: _onSearchSubmitted,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => _buildInitialState(),
                    loading: () => _buildLoadingState(),
                    error: (message) => _buildErrorState(message),
                    loaded: (products) => _buildLoadedState(products),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Text('输入关键词开始搜索'),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Text('错误: $message'),
    );
  }

  Widget _buildLoadedState(List<Product> products) {
    return const SizedBox.shrink();
  }
}
