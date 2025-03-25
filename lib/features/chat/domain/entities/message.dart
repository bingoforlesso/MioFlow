import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../product/domain/entities/product.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType {
  text,
  voice,
  image,
  productSuggestion,
  error,
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String content,
    required bool isUser,
    required MessageType type,
    required DateTime timestamp,
    String? imageUrl,
    List<Product>? products,
    List<Product>? suggestedProducts,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
