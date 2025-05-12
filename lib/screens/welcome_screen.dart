import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/models/ai_agent_model.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // App logo
                Center(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 24),
                // App name
                const Text(
                  'AI Chat Assistant',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Your personal AI assistant for conversations, tasks, and creative ideas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Onboarding slides
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildOnboardingPage(
                        title: 'Smart Conversations',
                        description:
                            'Chat with multiple AI models including GPT-4o, Claude, and Gemini to get answers, ideas, and assistance.',
                        icon: Icons.chat_bubble_outline,
                      ),
                      _buildOnboardingPage(
                        title: 'Knowledge Management',
                        description:
                            'Upload documents and create knowledge bases that your AI can reference during conversations.',
                        icon: Icons.auto_stories,
                      ),
                      _buildOnboardingPage(
                        title: 'Specialized Tools',
                        description:
                            'Use AI to generate emails, get reply suggestions, and access a library of powerful prompts.',
                        icon: Icons.build_circle_outlined,
                      ),
                    ],
                  ),
                ),

                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _totalPages,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _totalPages - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            context.go(
                                '/login'); // Go to login screen after completing onboarding
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6A3DE8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _currentPage < _totalPages - 1
                              ? 'Next'
                              : 'Get Started',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class NewUserHomeScreen extends StatelessWidget {
  const NewUserHomeScreen({super.key});

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
                        _buildWelcomeCard(context),
                        const SizedBox(height: 20),
                        _buildQuickStartSection(context),
                        const SizedBox(height: 20),
                        _buildPopularAssistants(context),
                        const SizedBox(height: 20),
                        _buildDiscoverFeatures(context),
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
        label: const Text('Start Chatting'),
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
                  'Welcome to',
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
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _showHelpDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.go(
                '/login'), // Direct to login since profile requires authentication
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to AI Chat Assistant!'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Here are some quick tips to get started:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 18, color: Color(0xFF6A3DE8)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'Tap "Start Chatting" to begin a conversation with an AI assistant'),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.smart_toy, size: 18, color: Color(0xFF6A3DE8)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'Try different AI models like GPT-4o, Claude, and Gemini for various tasks'),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.psychology, size: 18, color: Color(0xFF6A3DE8)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'Create custom assistants specialized for your specific needs'),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: Color(0xFF6A3DE8)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'Use the prompt library to get better results with effective prompts'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Text(
                'Need help with anything specific?',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 8),
              Text(
                'Just ask any AI assistant "How do I use this app?" for a guided tour!',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/chat/detail/new', extra: {
                'initialPrompt': 'How do I use this AI Chat Assistant app?',
                'setCursorToEnd': false,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6A3DE8),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ask AI for help'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
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
            '👋 Hello There!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A3DE8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'What would you like to do today?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your AI assistant is ready to help with questions, creative ideas, work tasks, and more.',
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
              _buildSuggestionChip(context, 'Help me get started'),
              _buildSuggestionChip(context, 'Write something creative'),
              _buildSuggestionChip(context, 'Answer a question'),
              _buildSuggestionChip(context, 'Give me ideas'),
              _buildSuggestionChip(context, 'Explain a concept'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String text) {
    return ActionChip(
      label: Text(text),
      backgroundColor: const Color(0xFFE0E0FD),
      onPressed: () {
        // Navigate to chat with this suggestion pre-filled
        context.go('/chat/detail/new', extra: {
          'initialPrompt': text,
          'setCursorToEnd': true,
        });
      },
    );
  }

  Widget _buildQuickStartSection(BuildContext context) {
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
                Icons.bolt,
                color: Color(0xFF6A3DE8),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Quick Start',
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
            'Get started with these beginner-friendly features:',
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
              _buildQuickStartCard(
                context,
                'Start a Chat',
                Icons.chat_bubble_outline,
                'Talk with an AI assistant about any topic',
                '/chat/detail/new',
                Colors.blue,
              ),
              _buildQuickStartCard(
                context,
                'Email Helper',
                Icons.email_outlined,
                'Draft professional emails with AI assistance',
                '/email/ai-generate',
                Colors.teal,
              ),
              _buildQuickStartCard(
                context,
                'Prompt Library',
                Icons.auto_awesome,
                'Discover effective prompts for better results',
                '/prompts',
                Colors.purple,
              ),
              _buildQuickStartCard(
                context,
                'Tutorial',
                Icons.school_outlined,
                'Learn how to get the most from AI Chat',
                '/home', // You can create a tutorial page later
                Colors.orange,
                onTap: () => _showTutorialDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon!'),
        content: const Text(
            'Interactive tutorials will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    String route,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () => context.go(route),
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

  Widget _buildPopularAssistants(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Assistants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6A3DE8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => context.go('/bot_management'),
              icon: const Icon(Icons.add),
              label: const Text('Create Custom Assistant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0E0FD),
                foregroundColor: const Color(0xFF6A3DE8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(BuildContext context, AIAgent agent) {
    return GestureDetector(
      onTap: () => context.go('/chat/detail/new', extra: {
        'initialAgent': agent,
      }),
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
            // New user badge for first assistant
            if (agent == AIAgents.agents.first)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Recommended',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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

  Widget _buildDiscoverFeatures(BuildContext context) {
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
                Icons.explore,
                color: Color(0xFF6A3DE8),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Discover More Features',
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
            'Explore these powerful capabilities to get the most out of your AI assistant:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            'Knowledge Management',
            'Upload documents and build custom knowledge bases',
            Icons.auto_stories,
            '/knowledge_management',
          ),
          _buildFeatureItem(
            context,
            'Email Reply Suggestions',
            'Get intelligent suggestions for your email responses',
            Icons.reply,
            '/email/reply-suggestions',
          ),
          _buildFeatureItem(
            context,
            'Custom AI Assistants',
            'Create specialized assistants for different tasks',
            Icons.psychology,
            '/bot_management',
          ),
          _buildFeatureItem(
            context,
            'Premium Features',
            'Unlock advanced capabilities with a subscription',
            Icons.star,
            '/purchase',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String route,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE0E0FD),
        child: Icon(
          icon,
          color: const Color(0xFF6A3DE8),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(route),
    );
  }
}
