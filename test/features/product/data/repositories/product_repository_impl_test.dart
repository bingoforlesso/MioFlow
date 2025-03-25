import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mio_ding/features/product/data/datasources/product_remote_data_source.dart';
import 'package:mio_ding/features/product/data/repositories/product_repository_impl.dart';
import 'package:mio_ding/features/product/domain/entities/product.dart';

@GenerateMocks([ProductRemoteDataSource])
void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(mockRemoteDataSource);
  });

  final testProducts = [
    Product(
      id: '1',
      code: 'P001',
      name: '测试产品1',
      brand: '品牌A',
      material_code: 'M001',
      output_brand: '输出品牌A',
      product_name: '产品名A',
      model: 'MODEL-A',
      specification: 'DN15',
      color: '红色',
      length: '100mm',
      weight: '1kg',
      wattage: '100W',
      pressure: '1.6MPa',
      degree: '90°',
      material: '不锈钢',
      price: 100.0,
      product_type: '阀门',
      usage_type: '工业用',
      sub_type: '球阀',
    ),
    Product(
      id: '2',
      code: 'P002',
      name: '测试产品2',
      brand: '品牌B',
      material_code: 'M002',
      output_brand: '输出品牌B',
      product_name: '产品名B',
      model: 'MODEL-B',
      specification: 'DN20',
      color: '蓝色',
      length: '150mm',
      weight: '1.5kg',
      wattage: '200W',
      pressure: '2.5MPa',
      degree: '180°',
      material: '碳钢',
      price: 200.0,
      product_type: '管件',
      usage_type: '民用',
      sub_type: '弯头',
    ),
  ];

  group('filterProducts', () {
    setUp(() {
      when(mockRemoteDataSource.getAllProducts())
          .thenAnswer((_) async => testProducts);
    });

    test('按品牌过滤 - 单一值', () async {
      final filters = {
        '品牌': ['品牌A'],
      };
      final result = await repository.filterProducts(filters);
      expect(result.length, 1);
      expect(result.first.brand, '品牌A');
    });

    test('按品牌过滤 - 多个值', () async {
      final filters = {
        '品牌': ['品牌A', '品牌B'],
      };
      final result = await repository.filterProducts(filters);
      expect(result.length, 2);
    });

    test('按材质过滤', () async {
      final filters = {
        '材质': ['不锈钢'],
      };
      final result = await repository.filterProducts(filters);
      expect(result.length, 1);
      expect(result.first.material, '不锈钢');
    });

    test('按规格和型号过滤', () async {
      final filters = {
        '规格': ['DN15'],
        '型号': ['MODEL-A'],
      };
      final result = await repository.filterProducts(filters);
      expect(result.length, 1);
      expect(result.first.specification, 'DN15');
      expect(result.first.model, 'MODEL-A');
    });

    test('按价格范围过滤', () async {
      final filters = {
        '价格': ['100.0'],
      };
      final result = await repository.filterProducts(filters);
      expect(result.length, 1);
      expect(result.first.price, 100.0);
    });

    test('按多个条件组合过滤', () async {
      final filters = {
        '品牌': ['品牌A'],
        '材质': ['不锈钢'],
        '产品类型': ['阀门'],
      };
      final result = await repository.filterProducts(filters);
      expect(result.length, 1);
      expect(result.first.brand, '品牌A');
      expect(result.first.material, '不锈钢');
      expect(result.first.product_type, '阀门');
    });

    test('使用中文字段名过滤', () async {
      final filters = {
        '商品名称': ['测试产品1'],
        '颜色': ['红色'],
        '长度': ['100mm'],
      };
      final result = await repository.filterProducts(filters);
      expect(result.length, 1);
      expect(result.first.name, '测试产品1');
      expect(result.first.color, '红色');
      expect(result.first.length, '100mm');
    });

    test('部分匹配过滤', () async {
      final filters = {
        '品牌': ['品牌'], // 应该匹配所有包含"品牌"的记录
      };
      final result = await repository.filterProducts(filters);
      expect(result.length, 2);
    });

    test('空值处理', () async {
      final testProductWithNull = Product(
        id: '3',
        code: 'P003',
        name: '测试产品3',
        brand: '品牌C',
        material_code: 'M003',
        color: null,
        material: null,
      );

      when(mockRemoteDataSource.getAllProducts())
          .thenAnswer((_) async => [...testProducts, testProductWithNull]);

      final filters = {
        '颜色': ['null'],
      };
      final result = await repository.filterProducts(filters);
      expect(result.length, 1);
      expect(result.first.id, '3');
    });

    test('无效字段处理', () async {
      final filters = {
        '不存在的字段': ['某个值'],
      };
      final result = await repository.filterProducts(filters);
      expect(result.length, 2); // 应返回所有产品
    });
  });
}
