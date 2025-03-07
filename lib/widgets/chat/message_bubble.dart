import 'package:flutter/material.dart';
import 'package:aichatbot/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              message.isUser
                  ? const Color(0xFF6A3DE8)
                  : const Color(0xFFF0F0FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser && message.agent != null) _buildAgentHeader(),
            SelectableText(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            _buildTimestamp(),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: message.agent!.color.withOpacity(0.2),
            child: Text(
              message.agent!.name.substring(0, 1),
              style: TextStyle(
                color: message.agent!.color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            message.agent!.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Text(
        _formatTime(message.timestamp),
        style: TextStyle(
          fontSize: 10,
          color: message.isUser ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
