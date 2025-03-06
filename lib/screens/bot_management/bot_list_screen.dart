import 'package:flutter/material.dart';
import 'package:aichatbot/models/ai_bot_model.dart';
import 'package:aichatbot/screens/create_bot_screen.dart';
import 'package:aichatbot/widgets/bots/bot_list_item.dart';

class BotListScreen extends StatefulWidget {
  const BotListScreen({super.key});

  @override
  State<BotListScreen> createState() => _BotListScreenState();
}

class _BotListScreenState extends State<BotListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data for AI bots
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

  List<AIBot> get _filteredBots {
    if (_searchQuery.isEmpty) return _bots;
    return _bots
        .where((bot) =>
            bot.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            bot.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  Future<void> _editBot(AIBot bot) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateBotScreen(editBot: bot),
      ),
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

  void _chatWithBot(AIBot bot) {
    // Navigate to chat with this bot
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chatting with ${bot.name}')),
    );
  }

  void _deleteBot(AIBot bot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _filteredBots.isEmpty ? _buildEmptyState() : _buildBotList(),
        ),
        _buildCreateButton(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm AI BOT...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
            _searchQuery.isEmpty ? Icons.smart_toy_outlined : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Chưa có AI BOT nào'
                : 'Không tìm thấy AI BOT nào phù hợp với "$_searchQuery"',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) const SizedBox(height: 24),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: _navigateToCreateBot,
              icon: const Icon(Icons.add),
              label: const Text('Tạo AI BOT đầu tiên'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

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
