import 'package:aichatbot/screens/knowledge_management/knowledge_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:aichatbot/screens/tabs/chat_tab.dart';
import 'package:aichatbot/screens/tabs/profile_tab.dart';
import 'package:aichatbot/screens/tabs/history_tab.dart';
import 'package:aichatbot/screens/tabs/settings_tab.dart';
import 'package:aichatbot/screens/bot_management/bot_list_screen.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;

class ChatAIScreen extends StatefulWidget {
  final int initialTabIndex;

  const ChatAIScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<ChatAIScreen> createState() => _ChatAIScreenState();
}

class _ChatAIScreenState extends State<ChatAIScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  // Define screens for the tabs
  late final List<Widget> _screens = [
    const ChatTab(),
    const BotListScreen(),
    const HistoryTab(),
    const ProfileTab(),
    const SettingsTab(),
  ];

  // Define colors for tabs - adding Knowledge Base color
  final List<Color> _colors = [
    const Color(0xFF6A3DE8), // Chat
    const Color(0xFF9B40D1), // Bots
    const Color(0xFF0F9D58), // Knowledge Base (not used in bottom nav)
    const Color(0xFF295BFF), // History
    const Color(0xFF315BFF), // Profile
    const Color(0xFF6A3DE8), // Settings
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToTab(int index) {
    // Handle the special case for Knowledge Base tab
    if (index == 2) {
      // Knowledge Base index
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KnowledgeManagementScreen(),
        ),
      );
    } else {
      // Adjust index if it's greater than Knowledge Base index (which isn't in bottom nav)
      setState(() {
        _currentIndex = index > 2 ? index - 1 : index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF0F0FF),
      drawer: MainAppDrawer(
        currentIndex: 0, // Index 0 corresponds to the Chat tab in the drawer
        onTabSelected: (index) => navigation_utils
            .handleDrawerNavigation(context, index, currentIndex: 0),
      ),
      appBar: AppBar(
        title: Text(
          _getTitle(),
          style: TextStyle(
            color: _colors[_currentIndex],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          if (_currentIndex == 0) // Only show on Chat tab
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  Navigator.of(context).pushNamed('/chat/detail/new'),
            ),
          if (_currentIndex == 1) // Only show on Bots tab
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.of(context).pushNamed('/bots/create'),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'AI Chat';
      case 1:
        return 'AI Bots';
      case 2:
        return 'Chat History';
      case 3:
        return 'My Profile';
      case 4:
        return 'Settings';
      default:
        return 'AI Chat Bot';
    }
  }
}
