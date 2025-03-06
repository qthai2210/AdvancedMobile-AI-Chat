import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:aichatbot/screens/tabs/chat_tab.dart';
import 'package:aichatbot/screens/tabs/profile_tab.dart';
import 'package:aichatbot/screens/tabs/history_tab.dart';
import 'package:aichatbot/screens/tabs/settings_tab.dart';
import 'package:aichatbot/screens/bot_management/bot_list_screen.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';

class ChatAIScreen extends StatefulWidget {
  const ChatAIScreen({super.key});

  @override
  State<ChatAIScreen> createState() => _ChatAIScreenState();
}

class _ChatAIScreenState extends State<ChatAIScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Define screens for the tabs
  late final List<Widget> _screens = [
    const ChatTab(),
    const BotListScreen(),
    const HistoryTab(),
    const ProfileTab(),
    const SettingsTab(),
  ];

  // Define colors for tabs
  final List<Color> _colors = [
    const Color(0xFF6A3DE8),
    const Color(0xFF9B40D1),
    const Color(0xFF295BFF),
    const Color(0xFF315BFF),
    const Color(0xFF6A3DE8), // Settings color
  ];

  // Define tab items
  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline),
      activeIcon: Icon(Icons.chat_bubble),
      label: 'Chat',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.smart_toy_outlined),
      activeIcon: Icon(Icons.smart_toy),
      label: 'Bots',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.history_outlined),
      activeIcon: Icon(Icons.history),
      label: 'History',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF0F0FF),
      drawer: MainAppDrawer(
        currentIndex: _currentIndex,
        onTabSelected: _onTabTapped,
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
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            _currentIndex < _bottomNavItems.length ? _currentIndex : 0,
        onTap: _onTabTapped,
        items: _bottomNavItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _colors[_currentIndex],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        elevation: 8,
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
