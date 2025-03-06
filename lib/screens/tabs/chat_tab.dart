import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/models/chat_thread.dart';
import 'package:aichatbot/screens/chat_detail_screen.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate bottom padding to avoid overlay with floating navigation bar
    final bottomPadding = MediaQuery.of(context).size.height * 0.05;

    return Column(
      children: [
        AppBar(
          title: const Text('AI Chat Bot'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.go('/login'),
            ),
          ],
        ),
        Expanded(
          child: Stack(
            children: [
              // Chat history list
              ChatHistoryListView(bottomPadding: bottomPadding),

              // New chat button with bottom padding to avoid overlay
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.9),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const ChatDetailScreen(isNewChat: true),
                          ));
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Tạo cuộc trò chuyện mới'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A3DE8),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatHistoryListView extends StatelessWidget {
  final double bottomPadding;
  final List<ChatThread> _chatThreads = [
    ChatThread(
      id: '1',
      title: 'Tìm hiểu về Machine Learning',
      lastMessage: 'Machine Learning là một phần của...',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      agentType: 'GPT-4',
    ),
    ChatThread(
      id: '2',
      title: 'Giải bài toán phức tạp',
      lastMessage: 'Để giải bài toán này, ta cần áp dụng...',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      agentType: 'Claude',
    ),
    ChatThread(
      id: '3',
      title: 'Lập trình Flutter',
      lastMessage: 'Flutter là framework phát triển ứng dụng...',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      agentType: 'GPT-3.5',
    ),
    ChatThread(
      id: '4',
      title: 'Tư vấn dự án',
      lastMessage: 'Để quản lý dự án hiệu quả, bạn nên...',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      agentType: 'GPT-4',
    ),
    ChatThread(
      id: '4',
      title: 'Tư vấn dự án',
      lastMessage: 'Để quản lý dự án hiệu quả, bạn nên...',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      agentType: 'GPT-4',
    ),
    ChatThread(
      id: '4',
      title: 'Tư vấn dự án',
      lastMessage: 'Để quản lý dự án hiệu quả, bạn nên...',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      agentType: 'GPT-4',
    ),
    ChatThread(
      id: '4',
      title: 'Tư vấn dự án',
      lastMessage: 'Để quản lý dự án hiệu quả, bạn nên...',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      agentType: 'GPT-4',
    ),
  ];

  ChatHistoryListView({
    super.key,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return _chatThreads.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có cuộc trò chuyện nào',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _chatThreads.length,
            padding: EdgeInsets.only(
                bottom: bottomPadding * 2), // Add padding at the bottom
            itemBuilder: (context, index) {
              final thread = _chatThreads[index];
              return ChatThreadItem(thread: thread);
            },
          );
  }
}

class ChatThreadItem extends StatelessWidget {
  final ChatThread thread;

  const ChatThreadItem({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          // Navigate to chat detail screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                threadId: thread.id,
                isNewChat: false,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6A3DE8).withOpacity(0.2),
          child: Text(
            thread.agentType.substring(0, 1),
            style: const TextStyle(
              color: Color(0xFF6A3DE8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          thread.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          thread.lastMessage,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTimeAgo(thread.timestamp),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                thread.agentType,
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: const Color(0xFFE0E0FD),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
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
