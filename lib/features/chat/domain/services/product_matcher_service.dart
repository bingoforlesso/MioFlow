import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/env.dart';

@lazySingleton
class ProductMatcherService {
  late final Dio _dio;

  ProductMatcherService() {
    _dio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: Env.connectionTimeout,
      receiveTimeout: Env.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  Future<List<Map<String, dynamic>>> matchProducts(String text) async {
    try {
      final response = await _dio.post(
        '/api/v1/products/match',
        data: {
          'text': text,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('商品匹配失败');
      }
    } catch (e) {
      throw '商品匹配服务暂时不可用，请稍后重试';
    }
  }

  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        '/api/v1/products/analyze-image',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('图片分析失败');
      }
    } catch (e) {
      throw '图片分析服务暂时不可用，请稍后重试';
    }
  }

  Future<Map<String, dynamic>> analyzeVoice(String audioPath) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioPath),
      });

      final response = await _dio.post(
        '/api/v1/products/analyze-voice',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('语音分析失败');
      }
    } catch (e) {
      throw '语音分析服务暂时不可用，请稍后重试';
    }
  }

  Future<Map<String, dynamic>> validateSpecifications(
    String productCode,
    Map<String, String> specifications,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/products/$productCode/validate-specs',
        data: specifications,
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('规格验证失败');
      }
    } catch (e) {
      throw '规格验证服务暂时不可用，请稍后重试';
    }
  }
}
