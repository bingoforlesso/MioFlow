import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../services/api_service.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/services/product_matcher_service.dart';
import '../../features/product/domain/services/product_service.dart';
import '../../features/product/domain/bloc/product_bloc.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/cart/domain/services/cart_service.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/chat/domain/services/chat_service.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/product/domain/services/search_suggestion_service.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
