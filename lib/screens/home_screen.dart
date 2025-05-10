import 'package:aichatbot/screens/bot_management/bot_list_screen.dart';
import 'package:aichatbot/screens/chat_detail_screen.dart';
import 'package:aichatbot/screens/knowledge_management/knowledge_management_screen.dart';
import 'package:aichatbot/screens/prompts/prompts_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/models/ai_agent_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF295BFF), Color(0xFF9B40D1)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ListView(
                      children: [
                        _buildFeaturedCard(),
                        const SizedBox(height: 20),
                        _buildAiToolsSection(context),
                        const SizedBox(height: 20),
                        _buildAgentSelection(context),
                        const SizedBox(height: 20),
                        _buildRecentChats(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/chat/detail/new'),
        label: const Text('New Chat'),
        icon: const Icon(Icons.chat),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6A3DE8),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/login_head.png'),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'AI Chat Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.go('/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Color(0xFF6A3DE8),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Featured',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A3DE8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'How can AI help you today?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask questions, get creative ideas, solve problems, and more with our AI assistants.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Interview preparation'),
              _buildSuggestionChip('Write a poem'),
              _buildSuggestionChip('Help with coding'),
              _buildSuggestionChip('Travel ideas'),
              _buildSuggestionChip('Explain quantum physics'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Builder(
      builder: (context) => ActionChip(
        label: Text(text),
        backgroundColor: const Color(0xFFE0E0FD),
        onPressed: () {
          // Navigate to chat with this suggestion
          context.go('/chat/detail/new');
        },
      ),
    );
  }

  Widget _buildAiToolsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.smart_toy,
                color: Color(0xFF6A3DE8),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'AI Tools',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A3DE8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Specialized AI tools to boost your productivity',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildToolCard(
                context,
                'AI Email Generator',
                Icons.email,
                'Create professional emails based on your ideas',
                '/email/ai-generate',
                Colors.blue,
              ),
              _buildToolCard(
                context,
                'Email Reply Suggestions',
                Icons.reply,
                'Get smart suggestions for email replies',
                '/email',
                Colors.teal,
              ),
              _buildToolCard(
                context,
                'Knowledge Management',
                Icons.auto_stories,
                'Manage and chat with your documents',
                '/knowledge_management',
                Colors.orange,
              ),
              _buildToolCard(
                context,
                'Prompt Library',
                Icons.collections_bookmark,
                'Access powerful prompts for any task',
                '/prompts',
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    String route,
    Color color,
  ) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentSelection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose an Assistant',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AIAgents.agents.length,
              itemBuilder: (context, index) {
                final agent = AIAgents.agents[index];
                return _buildAgentCard(context, agent);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(BuildContext context, AIAgent agent) {
    return GestureDetector(
      onTap: () => context.go('/chat/detail/new'),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: agent.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: agent.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: agent.color.withOpacity(0.2),
              child: Text(
                agent.name.substring(0, 1),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: agent.color,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              agent.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              agent.description.split(' ').take(3).join(' ') + '...',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentChats(BuildContext context) {
    // Sample recent chats
    final List<Map<String, dynamic>> recentChats = [
      {
        'title': 'Flutter Development',
        'message': 'How to implement bottom navigation?',
        'time': '2h ago',
        'agent': 'GPT-4',
      },
      {
        'title': 'Creative Writing',
        'message': 'Can you help me with a story idea?',
        'time': '1d ago',
        'agent': 'Claude',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Conversations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/chat'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...recentChats.map((chat) => _buildRecentChatItem(context, chat)),
          if (recentChats.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No recent conversations',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentChatItem(BuildContext context, Map<String, dynamic> chat) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF6A3DE8).withOpacity(0.2),
        child: Text(
          chat['agent'].substring(0, 1),
          style: const TextStyle(
            color: Color(0xFF6A3DE8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        chat['title'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat['message'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat['time'],
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: () => context.go('/chat/detail/1'),
    );
  }
}
