import 'package:flutter/material.dart';
import 'package:aichatbot/models/chat_thread.dart';

class ChatHistoryDrawer extends StatefulWidget {
  final Function(ChatThread) onThreadSelected;
  final VoidCallback onNewChatRequested;
  final List<ChatThread> chatHistory;

  const ChatHistoryDrawer({
    super.key,
    required this.onThreadSelected,
    required this.onNewChatRequested,
    required this.chatHistory,
  });

  @override
  State<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends State<ChatHistoryDrawer> {
  String _searchQuery = '';

  List<ChatThread> get _filteredHistory {
    if (_searchQuery.isEmpty) {
      return widget.chatHistory;
    }
    return widget.chatHistory
        .where((thread) =>
            thread.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            thread.lastMessage
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(),
          _buildSearchBar(),
          Expanded(
            child: _filteredHistory.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(),
          ),
          _buildNewChatButton(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF295BFF), Color(0xFF9B40D1)],
        ),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chat History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.chatHistory.length} conversations',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search conversations',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          isDense: true,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.chat_bubble_outline : Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No conversations yet'
                : 'No results found for "$_searchQuery"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      padding: const EdgeInsets.all(0),
      itemCount: _filteredHistory.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final thread = _filteredHistory[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            child: Text(
              thread.agentType.substring(0, 1),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            thread.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            thread.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Text(
            _formatTimeAgo(thread.timestamp),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          onTap: () {
            Navigator.pop(context); // Close drawer
            widget.onThreadSelected(thread);
          },
        );
      },
    );
  }

  Widget _buildNewChatButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context); // Close drawer
          widget.onNewChatRequested();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Chat'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
