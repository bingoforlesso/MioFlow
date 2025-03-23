import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/recommendation_service.dart';

class ProductRecommendationsScreen extends StatefulWidget {
  final String productCode;

  ProductRecommendationsScreen({required this.productCode});

  @override
  _ProductRecommendationsScreenState createState() => _ProductRecommendationsScreenState();
}

class _ProductRecommendationsScreenState extends State<ProductRecommendationsScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  List<Product> recommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final results = await _recommendationService.getRecommendations(
        widget.productCode,
      );
      setState(() {
        recommendations = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载推荐商品失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '为您推荐',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        if (isLoading)
          Center(child: CircularProgressIndicator())
        else if (recommendations.isEmpty)
          Center(child: Text('暂无推荐商品'))
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final product = recommendations[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 160,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          product.imageUrl,
                          height: 100,
                          width: 160,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '¥${product.price}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}