import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/message.dart';
import '../../../product/domain/entities/product.dart';
import '../../domain/services/chat_service.dart';
import '../../../product/domain/services/product_matcher_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';
part 'chat_bloc.freezed.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ProductMatcherService _productMatcherService;
  final _uuid = Uuid();
  final List<Message> _messages = [];

  ChatBloc(this._productMatcherService) : super(const ChatState.initial()) {
    on<_Started>(_onStarted);
    on<_MessageSent>(_onMessageSent);
    on<_VoiceMessageSent>(_onVoiceMessageSent);
    on<_ImageMessageSent>(_onImageMessageSent);
    on<_ProductSelected>(_onProductSelected);
    on<_HelpRequested>(_onHelpRequested);

    // 发送欢迎消息
    add(const ChatEvent.started());
  }

  FutureOr<void> _onStarted(_Started event, Emitter<ChatState> emit) async {
    emit(const ChatState.loading());

    try {
      final welcomeMessage = Message(
        id: _uuid.v4(),
        content: '欢迎使用MioDing智能管件搜索！\n\n'
            '您可以通过以下方式查询产品：\n'
            '1. 直接输入文字，例如：\n'
            '   - 要50个DN110 45度弯头\n'
            '   - 联塑 PVC-U给水管\n'
            '   - PPR热水管\n'
            '   - 黄铜球阀\n'
            '2. 语音描述您需要的产品\n'
            '3. 上传产品图片\n\n'
            '您还可以指定数量、规格、品牌等信息，我会为您匹配最合适的产品。',
        isUser: false,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      _messages.add(welcomeMessage);
      emit(ChatState.loaded(_messages));
    } catch (e) {
      emit(ChatState.error(e.toString()));
    }
  }

  FutureOr<void> _onMessageSent(
      _MessageSent event, Emitter<ChatState> emit) async {
    final userMessage = Message(
      id: _uuid.v4(),
      content: event.message,
      isUser: true,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    emit(ChatState.loaded(_messages));

    // 添加加载指示
    final loadingMessage = Message(
      id: _uuid.v4(),
      content: '正在搜索匹配商品...',
      isUser: false,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );
    _messages.add(loadingMessage);
    emit(ChatState.loaded(_messages));

    try {
      final products =
          await _productMatcherService.searchProducts(event.message);

      // 移除加载消息
      _messages.removeLast();

      String responseText;
      if (products.isEmpty) {
        responseText = '抱歉，没有找到匹配的商品。请尝试使用其他描述方式，或者直接搜索以下关键词：\n\n'
            '- 联塑 PVC-U给水管\n'
            '- PPR热水管\n'
            '- 黄铜球阀';
      } else {
        responseText = '找到以下匹配商品：\n\n';
        for (var product in products) {
          responseText +=
              '- ${product.name}，价格：¥${product.price?.toStringAsFixed(2) ?? "暂无价格"}\n';
        }
        responseText += '\n点击商品名称查看详情。';
      }

      final botMessage = Message(
        id: _uuid.v4(),
        content: responseText,
        isUser: false,
        type: MessageType.text,
        timestamp: DateTime.now(),
        products: products.isEmpty ? null : products,
      );

      _messages.add(botMessage);
      emit(ChatState.loaded(_messages));
    } catch (e) {
      // 移除加载消息
      _messages.removeLast();

      final errorMessage = Message(
        id: _uuid.v4(),
        content: '抱歉，搜索商品时出错：$e',
        isUser: false,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      _messages.add(errorMessage);
      emit(ChatState.loaded(_messages));
    }
  }

  FutureOr<void> _onVoiceMessageSent(
      _VoiceMessageSent event, Emitter<ChatState> emit) async {
    final userMessage = Message(
      id: _uuid.v4(),
      content: event.audioPath,
      isUser: true,
      type: MessageType.voice,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    emit(ChatState.loaded(_messages));

    try {
      final products =
          await _productMatcherService.searchProductsByVoice(event.audioPath);

      String responseText;
      if (products.isEmpty) {
        responseText = '抱歉，没有找到匹配的商品。请尝试使用其他描述方式。';
      } else {
        responseText = '找到以下匹配商品：';
      }

      final botMessage = Message(
        id: _uuid.v4(),
        content: responseText,
        isUser: false,
        type: MessageType.productSuggestion,
        timestamp: DateTime.now(),
        products: products.isEmpty ? null : products,
      );

      _messages.add(botMessage);
      emit(ChatState.loaded(_messages));
    } catch (e) {
      final errorMessage = Message(
        id: _uuid.v4(),
        content: '抱歉，处理语音消息时出错：$e',
        isUser: false,
        type: MessageType.error,
        timestamp: DateTime.now(),
      );

      _messages.add(errorMessage);
      emit(ChatState.loaded(_messages));
    }
  }

  FutureOr<void> _onImageMessageSent(
      _ImageMessageSent event, Emitter<ChatState> emit) async {
    final userMessage = Message(
      id: _uuid.v4(),
      content: '已上传图片',
      isUser: true,
      type: MessageType.image,
      timestamp: DateTime.now(),
      imageUrl: event.imagePath,
    );

    _messages.add(userMessage);
    emit(ChatState.loaded(_messages));

    try {
      final products =
          await _productMatcherService.searchProductsByImage(event.imagePath);

      String responseText;
      if (products.isEmpty) {
        responseText = '抱歉，没有找到匹配的商品。请尝试使用其他图片或描述方式。';
      } else {
        responseText = '找到以下匹配商品：';
      }

      final botMessage = Message(
        id: _uuid.v4(),
        content: responseText,
        isUser: false,
        type: MessageType.productSuggestion,
        timestamp: DateTime.now(),
        products: products.isEmpty ? null : products,
      );

      _messages.add(botMessage);
      emit(ChatState.loaded(_messages));
    } catch (e) {
      final errorMessage = Message(
        id: _uuid.v4(),
        content: '抱歉，处理图片消息时出错：$e',
        isUser: false,
        type: MessageType.error,
        timestamp: DateTime.now(),
      );

      _messages.add(errorMessage);
      emit(ChatState.loaded(_messages));
    }
  }

  FutureOr<void> _onProductSelected(
      _ProductSelected event, Emitter<ChatState> emit) {
    // TODO: Implement product selection handling
  }

  FutureOr<void> _onHelpRequested(
      _HelpRequested event, Emitter<ChatState> emit) {
    final helpMessage = Message(
      id: _uuid.v4(),
      content: '您可以通过以下方式查询产品：\n\n'
          '1. 直接输入文字，例如：\n'
          '   - 要50个DN110 45度弯头\n'
          '   - 联塑 PVC-U给水管\n'
          '   - PPR热水管\n'
          '   - 黄铜球阀\n'
          '2. 语音描述您需要的产品\n'
          '3. 上传产品图片\n\n'
          '您还可以指定数量、规格、品牌等信息，我会为您匹配最合适的产品。',
      isUser: false,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    _messages.add(helpMessage);
    emit(ChatState.loaded(_messages));
  }
}
