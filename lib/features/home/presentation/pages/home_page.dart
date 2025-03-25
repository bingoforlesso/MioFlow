import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('秒订'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.pushNamed('cart'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              context.goNamed('login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            const SizedBox(height: 16),
            _buildCategories(context),
            const SizedBox(height: 16),
            _buildFeaturedProducts(context),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.pushNamed('products');
              break;
            case 1:
              break;
            case 2:
              context.pushNamed('orders');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: '商品',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: '订单',
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Text(
          '秒订 - 您的专业五金工具供应商',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '商品分类',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildCategoryItem(
                context,
                icon: Icons.build,
                label: '工具',
                onTap: () => context.pushNamed('products'),
              ),
              _buildCategoryItem(
                context,
                icon: Icons.hardware,
                label: '五金',
                onTap: () => context.pushNamed('products'),
              ),
              _buildCategoryItem(
                context,
                icon: Icons.electrical_services,
                label: '电气',
                onTap: () => context.pushNamed('products'),
              ),
              _buildCategoryItem(
                context,
                icon: Icons.plumbing,
                label: '管道',
                onTap: () => context.pushNamed('products'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '热门商品',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
            children: List.generate(
              4,
              (index) {
                final productCode = index == 0
                    ? 'PIPE-001'
                    : index == 1
                        ? 'PIPE-002'
                        : index == 2
                            ? 'VALVE-001'
                            : 'PIPE-001';
                final productName = index == 0
                    ? '联塑 PVC-U给水管 DN110'
                    : index == 1
                        ? '联塑 PVC-U给水管 DN75'
                        : index == 2
                            ? '联塑 PVC-U球阀 DN50'
                            : '联塑 PVC-U给水管 DN110';
                final productPrice = index == 0
                    ? 158.00
                    : index == 1
                        ? 89.00
                        : index == 2
                            ? 45.00
                            : 158.00;

                return _buildProductCard(
                  context,
                  name: productName,
                  price: productPrice,
                  imageUrl: null,
                  onTap: () => context.pushNamed(
                    'product_details',
                    pathParameters: {'productCode': productCode},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context, {
    required String name,
    required double price,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
