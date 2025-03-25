import 'package:injectable/injectable.dart';
import '../entities/message.dart';

@lazySingleton
class ChatService {
  Future<List<Message>> getMessages() async {
    // TODO: 实现从数据库获取消息历史
    return [];
  }

  Future<String> sendMessage(String text) async {
    // TODO: 实现消息处理逻辑
    return '收到您的消息：$text';
  }

  Future<String> sendImage(String imageUrl) async {
    // TODO: 实现图片处理逻辑
    return '收到您的图片，正在分析...';
  }
}
