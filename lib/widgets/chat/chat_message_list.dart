import 'package:flutter/material.dart';
import 'package:aichatbot/models/message_model.dart';
import 'package:aichatbot/widgets/chat/message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final List<Message> messages;
  final ScrollController scrollController;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(message: message);
      },
    );
  }
}
