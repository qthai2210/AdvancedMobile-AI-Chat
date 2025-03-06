import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:go_router/go_router.dart';

class ChatAIScreen extends StatefulWidget {
  const ChatAIScreen({super.key});

  @override
  State<ChatAIScreen> createState() => _ChatAIScreenState();
}

class _ChatAIScreenState extends State<ChatAIScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ChatTab(),
    const ProfileTab(),
    const HistoryTab(),
    const SettingsTab(),
  ];

  // Define colors for tabs
  final List<Color> _colors = [
    const Color(0xFF6A3DE8),
    const Color(0xFF9B40D1),
    const Color(0xFF295BFF),
    const Color(0xFF315BFF),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color unselectedColor = Colors.grey;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0FF),
      body: SafeArea(
        child: BottomBar(
          fit: StackFit.expand,
          icon:
              (width, height) => Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: null,
                  icon: Icon(
                    Icons.arrow_upward_rounded,
                    color: unselectedColor,
                    size: width,
                  ),
                ),
              ),
          borderRadius: BorderRadius.circular(20),
          duration: const Duration(milliseconds: 500),
          curve: Curves.decelerate,
          showIcon: true,
          width: MediaQuery.of(context).size.width * 0.8,
          barColor:
              _colors[_currentIndex].computeLuminance() > 0.5
                  ? Colors.white
                  : Colors.white,
          start: 2,
          end: 0,
          //bottom: 16,
          offset: 10,
          barAlignment: Alignment.bottomCenter,
          iconHeight: 35,
          iconWidth: 35,
          reverse: false,
          barDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          iconDecoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF295BFF), Color(0xFF9B40D1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          hideOnScroll: true,
          scrollOpposite: false,
          onBottomBarHidden: () {},
          onBottomBarShown: () {},
          child: TabBar(
            controller: _tabController,
            indicatorPadding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: _colors[_currentIndex], width: 4),
              insets: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            ),
            tabs: [
              Tab(
                icon: Icon(
                  _currentIndex == 0
                      ? Icons.chat_bubble
                      : Icons.chat_bubble_outline,
                  color: _currentIndex == 0 ? _colors[0] : unselectedColor,
                ),
                text: 'Chat',
              ),
              Tab(
                icon: Icon(
                  _currentIndex == 1 ? Icons.person : Icons.person_outline,
                  color: _currentIndex == 1 ? _colors[1] : unselectedColor,
                ),
                text: 'Profile',
              ),
              Tab(
                icon: Icon(
                  _currentIndex == 2 ? Icons.history : Icons.history_outlined,
                  color: _currentIndex == 2 ? _colors[2] : unselectedColor,
                ),
                text: 'History',
              ),
              Tab(
                icon: Icon(
                  _currentIndex == 3 ? Icons.settings : Icons.settings_outlined,
                  color: _currentIndex == 3 ? _colors[3] : unselectedColor,
                ),
                text: 'Settings',
              ),
            ],
            labelColor: _colors[_currentIndex],
            unselectedLabelColor: unselectedColor,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          body:
              (context, controller) => TabBarView(
                controller: _tabController,
                dragStartBehavior: DragStartBehavior.down,
                physics: const BouncingScrollPhysics(),
                children: _screens,
              ),
        ),
      ),
    );
  }
}

// Chat Tab - Main content
class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble,
                  size: 80,
                  color: Color(0xFF6A3DE8),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Start chatting with AI',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ask any question or start a conversation',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      // Start a new chat
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A3DE8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('New Chat'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Other tabs - simple placeholders
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, size: 80, color: Color(0xFF6A3DE8)),
          ),
          const SizedBox(height: 20),
          const Text(
            'User Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'tushari23@gmail.com',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 80, color: Color(0xFF6A3DE8)),
          const SizedBox(height: 20),
          const Text(
            'Chat History',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Your previous conversations will appear here',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 80, color: Color(0xFF6A3DE8)),
          const SizedBox(height: 20),
          const Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Customize your app preferences',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
