import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/product/domain/bloc/product_bloc.dart';
import 'features/product/presentation/bloc/product_list_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env: $e');
    // Fallback to default values if env file is not found
    dotenv.testLoad(fileInput: '''
API_BASE_URL=http://localhost:8000
API_VERSION=v1
CONNECTION_TIMEOUT=30
RECEIVE_TIMEOUT=30
JWT_SECRET=your_development_jwt_secret_key
    ''');
  }

  // Initialize dependency injection
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: getIt<AuthProvider>(),
        ),
        BlocProvider.value(
          value: getIt<AuthBloc>(),
        ),
        BlocProvider.value(
          value: getIt<CartBloc>(),
        ),
        BlocProvider.value(
          value: getIt<ChatBloc>(),
        ),
        BlocProvider.value(
          value: getIt<ProductBloc>(),
        ),
        BlocProvider.value(
          value: getIt<ProductListBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: '秒订',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF2196F3),
          fontFamily: 'Roboto',
          textTheme: Theme.of(context).textTheme.apply(
                fontFamily: 'Roboto',
              ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
