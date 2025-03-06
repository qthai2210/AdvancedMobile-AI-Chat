import 'package:flutter/material.dart';
import 'package:aichatbot/models/chat_thread.dart';

class ChatHistoryOverlay extends StatelessWidget {
  final List<ChatThread> chatHistory;
  final VoidCallback onClose;
  final Function(ChatThread) onThreadSelected;

  const ChatHistoryOverlay({
    super.key,
    required this.chatHistory,
    required this.onClose,
    required this.onThreadSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    'Lịch sử cuộc trò chuyện',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: chatHistory.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final thread = chatHistory[index];
                  return ChatHistoryItem(
                    thread: thread,
                    onTap: () => onThreadSelected(thread),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatHistoryItem extends StatelessWidget {
  final ChatThread thread;
  final VoidCallback onTap;

  const ChatHistoryItem({
    super.key,
    required this.thread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
        child: Text(
          thread.agentType.substring(0, 1),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      title: Text(thread.title),
      subtitle: Text(
        thread.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTimeAgo(thread.timestamp),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: onTap,
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
