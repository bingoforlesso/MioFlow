import 'package:flutter/material.dart';
import '../services/delivery_service.dart';
import '../models/delivery_estimation.dart';

class DeliveryEstimationWidget extends StatefulWidget {
  final String orderNo;
  final int dealerId;
  final Map<String, dynamic> deliveryAddress;

  DeliveryEstimationWidget({
    required this.orderNo,
    required this.dealerId,
    required this.deliveryAddress,
  });

  @override
  _DeliveryEstimationWidgetState createState() => _DeliveryEstimationWidgetState();
}

class _DeliveryEstimationWidgetState extends State<DeliveryEstimationWidget> {
  final DeliveryService _deliveryService = DeliveryService();
  DeliveryEstimation? estimation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEstimation();
  }

  Future<void> _loadEstimation() async {
    try {
      final result = await _deliveryService.estimateDeliveryTime(
        widget.orderNo,
        widget.dealerId,
        widget.deliveryAddress,
      );
      setState(() {
        estimation = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取配送时间预估失败')),
      );
    }
  }

  String _formatEstimation() {
    if (estimation == null) return '暂无预估信息';
    
    final hours = estimation!.estimatedHours.round();
    if (hours < 24) {
      return '预计 $hours 小时内送达';
    } else {
      final days = (hours / 24).ceil();
      return '预计 $days 天内送达';
    }
  }

  Widget _buildFactorInfo() {
    if (estimation == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '配送距离: ${estimation!.distance.toStringAsFixed(1)}公里',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        if (estimation!.factors['weather'] != 1.0)
          Text(
            '天气影响: ${(estimation!.factors['weather'] * 100 - 100).abs().toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        if (estimation!.factors['traffic'] != 1.0)
          Text(
            '交通影响: ${(estimation!.factors['traffic'] * 100 - 100).abs().toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  '配送时间预估',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            SizedBox(height: 16),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatEstimation(),
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildFactorInfo(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}