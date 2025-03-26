import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../domain/bloc/product_bloc.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/widgets/chat_widget.dart';
import '../../domain/entities/product.dart';
import 'product_details_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/filter_group.dart';
import '../../domain/models/filter_state.dart';
import '../../domain/models/filter_option.dart';
import '../bloc/product_list_bloc.dart';
import '../widgets/filter_panel.dart';
import '../widgets/product_grid.dart';

class ProductListPage extends StatefulWidget {
  final bool isHomePage;

  const ProductListPage({
    super.key,
    this.isHomePage = false,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _messageController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeSpeechToText();
    context.read<ProductListBloc>().add(const ProductListEvent.started());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ProductListBloc>().add(const ProductListEvent.started());
  }

  Future<void> _initializeSpeechToText() async {
    bool available = await _speechToText.initialize();
    if (mounted) {
      setState(() {
        _isListening = available;
      });
    }
  }

  void _loadProducts() {
    context.read<ProductBloc>().add(const ProductEvent.loadProducts());
  }

  void _onSearchSubmitted(String value) {
    if (value.isNotEmpty) {
      context
          .read<ProductBloc>()
          .add(ProductEvent.searchProducts(query: value));
    } else {
      _loadProducts();
    }
  }

  void onSearch(String query) {
    if (query.isNotEmpty) {
      context
          .read<ProductBloc>()
          .add(ProductEvent.searchProducts(query: query));
    }
  }

  void _onProductTap(BuildContext context, Product product) {
    context.pushNamed(
      'product_details',
      pathParameters: {'productId': product.id},
      extra: product,
    );
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      final available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        await _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              setState(() => _isListening = false);
              if (result.recognizedWords.isNotEmpty) {
                context.read<ChatBloc>().add(
                      ChatEvent.messageSent(result.recognizedWords),
                    );
              }
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<ChatBloc>().add(
            ChatEvent.imageMessageSent(image.path),
          );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<ChatBloc>().add(
            ChatEvent.messageSent(_messageController.text.trim()),
          );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '秒订',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              authProvider.isLoggedIn
                  ? authProvider.companyName ?? '未设置单位名称'
                  : '未登录',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              if (authProvider.isLoggedIn) {
                context.pushNamed('cart');
              } else {
                context.pushNamed('login');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              context.goNamed('login');
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(
                  onSearch: (query) {
                    // TODO: Implement search
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '搜索产品...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                context.read<ProductListBloc>().add(
                      ProductListEvent.search(query: value),
                    );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductListBloc, ProductListState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const Center(child: Text('加载中...')),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  loaded: (products, filteredProducts, filterGroups,
                      selectedFilters, favoriteFilters, isLoading, error) {
                    if (filteredProducts.isEmpty) {
                      return const Center(child: Text('没有找到符合条件的产品'));
                    }
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (error != null) {
                      return Center(child: Text('错误: $error'));
                    }
                    return Row(
                      children: [
                        // 左侧筛选面板
                        SizedBox(
                          width: 280,
                          child: Card(
                            margin: const EdgeInsets.all(8),
                            child: FilterPanel(
                              filterGroups: filterGroups,
                              selectedFilters:
                                  Map<FilterAttribute, Set<String>>.from(
                                selectedFilters.map(
                                  (key, value) => MapEntry(key, {value}),
                                ),
                              ),
                              onFilterSelected: (attribute, value, isSelected) {
                                context.read<ProductListBloc>().add(
                                      ProductListEvent.filterSelected(
                                        attribute: attribute,
                                        value: value,
                                        isSelected: isSelected,
                                      ),
                                    );
                              },
                              onClearFilters: () {
                                context.read<ProductListBloc>().add(
                                      const ProductListEvent.clearFilters(),
                                    );
                              },
                              onFavoriteToggle: (group) {
                                context.read<ProductListBloc>().add(
                                      ProductListEvent.toggleFavorite(
                                        option: FilterOption(
                                          filterAttribute: group.attribute,
                                          value: group.attribute.name,
                                          count: 0,
                                        ),
                                      ),
                                    );
                              },
                              favoriteFilters: favoriteFilters
                                  .map((option) =>
                                      FilterAttribute.values.firstWhere(
                                        (attr) => attr.name == option.value,
                                      ))
                                  .toSet(),
                            ),
                          ),
                        ),
                        // 右侧产品列表
                        Expanded(
                          child: ProductGrid(
                            products: filteredProducts,
                            onTap: (product) => _onProductTap(context, product),
                          ),
                        ),
                      ],
                    );
                  },
                  error: (message) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('错误: $message'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ProductListBloc>().add(
                                  const ProductListEvent.started(),
                                );
                          },
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // 底部输入栏
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    color: _isListening ? Colors.red : null,
                  ),
                  onPressed: _startListening,
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.isHomePage ? 0 : 1,
        onTap: (index) {
          switch (index) {
            case 0:
              if (!widget.isHomePage) {
                context.goNamed('home');
              }
              break;
            case 1:
              if (widget.isHomePage) {
                context.goNamed('products');
              }
              break;
            case 2:
              if (authProvider.isLoggedIn) {
                context.pushNamed('orders');
              } else {
                context.pushNamed('login');
              }
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: '产品',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: '订单',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _speechToText.stop();
    super.dispose();
  }
}

class ProductSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;

  ProductSearchDelegate({required this.onSearch});

  void _loadProducts() {
    onSearch('');
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: Text('请输入搜索关键词')),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (products) => products.isEmpty
              ? const Center(child: Text('暂无数据'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl ?? '',
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(product.name ?? ''),
                      subtitle: Text(product.description ?? ''),
                      onTap: () {
                        close(context, null);
                        context.pushNamed(
                          'product_details',
                          pathParameters: {'productId': product.id},
                          extra: product,
                        );
                      },
                    );
                  },
                ),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('错误: $message'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadProducts,
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
