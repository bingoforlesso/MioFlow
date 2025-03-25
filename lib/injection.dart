import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'core/database/database.dart';
import 'features/auth/domain/services/auth_service.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/domain/services/product_matcher_service.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // 注册数据库
  getIt.registerSingleton<Database>(Database());
  await getIt<Database>().init();

  // 注册仓库
  getIt.registerSingleton<ProductRepository>(
    ProductRepository(getIt<Database>()),
  );

  // 注册服务
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<ProductMatcherService>(
    ProductMatcherService(getIt<ProductRepository>()),
  );
}
