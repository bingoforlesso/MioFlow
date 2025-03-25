import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/product/presentation/pages/product_search_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/address/presentation/pages/address_list_page.dart';
import '../../features/address/presentation/pages/address_form_page.dart';
import '../../features/order/presentation/pages/order_list_page.dart';
import '../../features/order/presentation/pages/order_details_page.dart';
import '../../features/product/presentation/pages/product_details_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/domain/entities/product.dart';

@lazySingleton
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isLoggedIn;

      // 只有购物车和订单页面需要登录
      final needsAuth = ['/cart', '/orders'].any(
        (path) => state.matchedLocation.startsWith(path),
      );

      if (needsAuth && !isLoggedIn) {
        return '/login?redirect=${state.matchedLocation}';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const ProductListPage(isHomePage: true),
      ),
      GoRoute(
        path: '/home',
        name: 'home_old',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return LoginPage(redirect: redirect);
        },
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductListPage(isHomePage: false),
      ),
      GoRoute(
        path: '/products/:productId',
        name: 'product_details',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailsPage(product: product);
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrderListPage(),
      ),
      GoRoute(
        path: '/orders/:orderNo',
        name: 'order_details',
        builder: (context, state) {
          final orderNo = state.pathParameters['orderNo']!;
          return OrderDetailsPage(orderNo: orderNo);
        },
      ),
      GoRoute(
        path: '/address',
        name: 'address_list',
        builder: (context, state) => const AddressListPage(),
      ),
      GoRoute(
        path: '/address/new',
        name: 'address_form',
        builder: (context, state) => const AddressFormPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('错误: ${state.error}'),
      ),
    ),
  );
}
