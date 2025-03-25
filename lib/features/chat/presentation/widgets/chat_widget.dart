import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../domain/entities/message.dart';
import '../../../product/domain/entities/product.dart';
import '../bloc/chat_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../product/domain/services/product_matcher_service.dart';
import 'package:get_it/get_it.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = Uuid();
  bool _isLoading = false;
  late final ProductMatcherService _productMatcher;

  @override
  void initState() {
    super.initState();
    _initializeSpeechToText();
    _productMatcher = GetIt.I<ProductMatcherService>();
  }

  // 转换产品类型
  Product _convertProduct(Product product) {
    return product; // 不需要转换，直接返回原始产品
  }

  Future<void> _initializeSpeechToText() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {});
    }
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        await _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              context
                  .read<ChatBloc>()
                  .add(ChatEvent.voiceMessageSent(result.recognizedWords));
              setState(() => _isListening = false);
            }
          },
        );
      }
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<ChatBloc>().add(ChatEvent.imageMessageSent(image.path));
    }
  }

  Future<void> _handleTextSubmitted(String text) async {
    if (text.isEmpty) return;

    try {
      // 清除输入框
      _messageController.clear();

      // 发送用户消息到 ChatBloc
      context.read<ChatBloc>().add(ChatEvent.messageSent(text));

      // 设置加载状态
      setState(() {
        _isLoading = true;
      });

      // 搜索产品
      final domainProducts = await _productMatcher.searchProducts(text);
      final chatProducts = domainProducts.map(_convertProduct).toList();

      // 不需要额外发送事件，因为 messageSent 事件已经触发了产品搜索
    } catch (e) {
      debugPrint('搜索商品时出错: $e');
      context.read<ChatBloc>().add(
            ChatEvent.helpRequested(),
          );
    } finally {
      // 清除加载状态
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: state.when(
                initial: () => const Center(
                  child: Text('开始聊天'),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                loaded: (messages) => ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageBubble(message: message);
                  },
                ),
                error: (message) => Center(
                  child: Text('错误: $message'),
                ),
              ),
            ),
            _buildInputArea(),
          ],
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _pickImage,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: '输入消息...',
                border: InputBorder.none,
              ),
              onSubmitted: _handleTextSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () =>
                _handleTextSubmitted(_messageController.text.trim()),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _speechToText.cancel();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: message.isUser ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(message.content),
          ),
          if (message.suggestedProducts != null &&
              message.suggestedProducts!.isNotEmpty)
            _buildProductList(message.suggestedProducts!),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductCard(
              product: product,
              onTap: () {
                // 处理点击产品卡片的事件，例如导航到产品详情页
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
              ),
            ),
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '¥${product.price?.toStringAsFixed(2) ?? "暂无价格"}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
