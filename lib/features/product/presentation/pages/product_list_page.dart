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
    if (!widget.isHomePage) {
      _loadProducts();
    }
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
      context.read<ProductBloc>().add(ProductEvent.searchProducts(value));
    } else {
      _loadProducts();
    }
  }

  void onSearch(String query) {
    if (query.isNotEmpty) {
      context.read<ProductBloc>().add(ProductEvent.searchProducts(query));
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
                    context
                        .read<ProductBloc>()
                        .add(ProductEvent.searchProducts(query));
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: widget.isHomePage
          ? BlocProvider(
              create: (context) =>
                  GetIt.I<ChatBloc>()..add(const ChatEvent.started()),
              child: const ChatWidget(),
            )
          : _buildProductList(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.isHomePage ? 0 : 1,
        selectedItemColor: theme.primaryColor,
        onTap: (index) {
          switch (index) {
            case 0:
              if (!widget.isHomePage) {
                context.goNamed('home');
              }
              break;
            case 1:
              if (widget.isHomePage) {
                context.pushNamed('products');
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
            icon: Icon(Icons.list),
            label: '商品',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: '订单',
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: Text('请搜索商品')),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (products) {
            if (products.isEmpty) {
              return const Center(child: Text('未找到商品'));
            }
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: product.image_url != null
                        ? CachedNetworkImage(
                            imageUrl: product.image_url!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text(product.name),
                    subtitle: Text(product.specification ?? ''),
                    trailing:
                        Text('¥${product.price?.toStringAsFixed(2) ?? 'N/A'}'),
                    onTap: () => _onProductTap(context, product),
                  ),
                );
              },
            );
          },
          error: (message) => Center(child: Text('错误：$message')),
        );
      },
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
          loaded: (products) {
            if (products.isEmpty) {
              return const Center(child: Text('没有找到相关产品'));
            }
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: product.image_url != null
                        ? CachedNetworkImage(
                            imageUrl: product.image_url!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text(product.name),
                    subtitle: Text(product.specification ?? ''),
                    trailing:
                        Text('¥${product.price?.toStringAsFixed(2) ?? 'N/A'}'),
                    onTap: () {
                      close(context, null);
                      context.pushNamed(
                        'product_details',
                        pathParameters: {'productId': product.id},
                        extra: product,
                      );
                    },
                  ),
                );
              },
            );
          },
          error: (message) => Center(child: Text('错误：$message')),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // 可以在这里实现搜索建议功能
  }
}
