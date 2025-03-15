import 'package:flutter/material.dart';
import 'package:aichatbot/models/ai_bot_model.dart';
import 'package:aichatbot/screens/create_bot_screen.dart';
import 'package:aichatbot/widgets/bots/bot_list_item.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;

/// A screen that displays and manages a list of AI bots.
///
/// This screen allows users to:
/// * View a list of existing AI bots
/// * Search for specific bots
/// * Create new bots
/// * Edit existing bots
/// * Delete bots
/// * Share bots across different platforms
class BotListScreen extends StatefulWidget {
  const BotListScreen({super.key});

  @override
  State<BotListScreen> createState() => _BotListScreenState();
}

/// State class for [BotListScreen] that manages the UI and bot data.
class _BotListScreenState extends State<BotListScreen> {
  /// Controller for the search input field
  final TextEditingController _searchController = TextEditingController();

  /// Current search query entered by the user
  String _searchQuery = '';

  /// Mock data representing the list of AI bots
  final List<AIBot> _bots = [
    AIBot(
      id: '1',
      name: 'Customer Support Bot',
      description:
          'Handles customer inquiries and common questions about our products and services',
      iconData: Icons.support_agent,
      color: Colors.blue,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    AIBot(
      id: '2',
      name: 'HR Assistant',
      description:
          'Answers questions about company policies, benefits, and procedures',
      iconData: Icons.people,
      color: Colors.green,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    AIBot(
      id: '3',
      name: 'Product Recommendation',
      description: 'Suggests products based on customer preferences and needs',
      iconData: Icons.shopping_cart,
      color: Colors.orange,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  /// Returns a filtered list of bots based on the current search query.
  ///
  /// If [_searchQuery] is empty, returns all bots.
  /// Otherwise, returns bots whose name or description contain the search query.
  List<AIBot> get _filteredBots {
    if (_searchQuery.isEmpty) return _bots;
    return _bots
        .where(
          (bot) =>
              bot.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              bot.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Navigates to the bot creation screen and handles the result.
  ///
  /// If a new bot is created, adds it to the [_bots] list.
  Future<void> _navigateToCreateBot() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateBotScreen()),
    );

    if (result != null && result is AIBot) {
      setState(() {
        _bots.add(result);
      });
    }
  }

  /// Opens the edit screen for an existing bot.
  ///
  /// Handles both editing and deletion results from the edit screen.
  /// [bot] The AI bot to be edited.
  Future<void> _editBot(AIBot bot) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateBotScreen(editBot: bot)),
    );

    if (result != null) {
      if (result == 'delete') {
        setState(() {
          _bots.removeWhere((b) => b.id == bot.id);
        });
      } else if (result is AIBot) {
        setState(() {
          final index = _bots.indexWhere((b) => b.id == bot.id);
          if (index != -1) {
            _bots[index] = result;
          }
        });
      }
    }
  }

  /// Initiates a chat session with the selected bot.
  ///
  /// [bot] The AI bot to chat with.
  void _chatWithBot(AIBot bot) {
    // Navigate to chat with this bot
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Chatting with ${bot.name}')));
  }

  /// Shows a confirmation dialog and handles bot deletion.
  ///
  /// [bot] The AI bot to be deleted.
  void _deleteBot(AIBot bot) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa Bot'),
            content: Text('Bạn có chắc muốn xóa bot "${bot.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _bots.removeWhere((b) => b.id == bot.id);
                  });
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Bots'),
        actions: [
          // Add share dropdown menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            tooltip: 'Share AI Chat',
            onSelected: _handleShare,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'slack',
                    child: Row(
                      children: [
                        Icon(
                          Icons.workspaces_outlined,
                          color: Color(0xFF4A154B),
                        ),
                        SizedBox(width: 12),
                        Text('Publish to Slack'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'telegram',
                    child: Row(
                      children: [
                        Icon(Icons.send, color: Color(0xFF0088CC)),
                        SizedBox(width: 12),
                        Text('Share to Telegram'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'messenger',
                    child: Row(
                      children: [
                        Icon(Icons.message, color: Color(0xFF0084FF)),
                        SizedBox(width: 12),
                        Text('Send to Messenger'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      drawer: MainAppDrawer(
        currentIndex: 1, // Index 1 corresponds to the AI Bots tab in the drawer
        onTabSelected:
            (index) => navigation_utils.handleDrawerNavigation(
              context,
              index,
              currentIndex: 1,
            ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredBots.isEmpty ? _buildEmptyState() : _buildBotList(),
          ),
          _buildCreateButton(),
        ],
      ),
    );
  }

  /// Handles sharing the AI chat to different platforms.
  ///
  /// [platform] The platform to share to ('slack', 'telegram', or 'messenger').
  void _handleShare(String platform) {
    String message = '';

    switch (platform) {
      case 'slack':
        message = 'Publishing to Slack...';
        break;
      case 'telegram':
        message = 'Sharing to Telegram...';
        break;
      case 'messenger':
        message = 'Sending to Messenger...';
        break;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Builds the search bar widget with clear functionality.
  ///
  /// Returns a [TextField] wrapped in padding for searching bots.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm AI BOT...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  /// Builds the empty state widget shown when no bots exist or no search results found.
  ///
  /// Returns a centered [Column] with appropriate messaging and actions.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.smart_toy_outlined : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Chưa có AI BOT nào'
                : 'Không tìm thấy AI BOT nào phù hợp với "$_searchQuery"',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) const SizedBox(height: 24),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: _navigateToCreateBot,
              icon: const Icon(Icons.add),
              label: const Text('Tạo AI BOT đầu tiên'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the scrollable list of AI bots.
  ///
  /// Returns a [ListView.builder] containing [BotListItem] widgets.
  Widget _buildBotList() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
      itemCount: _filteredBots.length,
      itemBuilder: (context, index) {
        final bot = _filteredBots[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BotListItem(
            bot: bot,
            onEdit: () => _editBot(bot),
            onChat: () => _chatWithBot(bot),
            onDelete: () => _deleteBot(bot),
          ),
        );
      },
    );
  }

  /// Builds the "Create AI BOT" button fixed at the bottom of the screen.
  ///
  /// Returns a padded [FloatingActionButton.extended] widget.
  Widget _buildCreateButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: _navigateToCreateBot,
          label: const Text('Tạo AI BOT mới'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}
