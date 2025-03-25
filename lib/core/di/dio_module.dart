import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioModule {
  @singleton
  Dio get dio {
    // 使用端口8000连接后端服务器
    final dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000', // 后端服务器端口
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加拦截器用于调试
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('发送请求: ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('收到响应: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('请求错误: ${e.message}');
        if (e.type == DioExceptionType.connectionError) {
          print('连接错误，请确保后端服务器正在运行且端口配置正确');
        }
        return handler.next(e);
      },
    ));

    return dio;
  }
}
