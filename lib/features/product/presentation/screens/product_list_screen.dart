import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/filter_group.dart';
import '../../domain/models/filter_option.dart';
import '../../domain/services/filter_service.dart';
import '../bloc/product_list_bloc.dart';
import '../widgets/filter_panel.dart';
import '../widgets/product_grid.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final Map<FilterAttribute, Set<String>> _selectedFilters = {};
  List<FilterGroup> _filterGroups = [];
  final FilterService _filterService = FilterService();

  @override
  void initState() {
    super.initState();
    context.read<ProductListBloc>().add(const ProductListEvent.loadProducts());
  }

  void _handleFilterOptionSelected(FilterAttribute attribute, String value) {
    setState(() {
      _selectedFilters.putIfAbsent(attribute, () => {});
      if (_selectedFilters[attribute]!.contains(value)) {
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
        title: const Text('产品列表'),
      ),
      body: BlocConsumer<ProductListBloc, ProductListState>(
        listener: (context, state) {
          state.maybeWhen(
            loaded: (products) {
              _filterGroups = _filterService.extractFilterGroups(products);
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text('错误: $message')),
            loaded: (products) {
              final filteredProducts =
                  _filterService.applyFilters(products, _selectedFilters);
              return Row(
                children: [
                  FilterPanel(
                    filterGroups: _filterGroups,
                    selectedFilters: _selectedFilters,
                    onOptionSelected: _handleFilterOptionSelected,
                    onClearAll: _clearAllFilters,
                  ),
                  Expanded(
                    child: ProductGrid(
                      products: filteredProducts,
                      onProductTap: (product) {
                        // TODO: Navigate to product detail
                      },
                    ),
                  ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
