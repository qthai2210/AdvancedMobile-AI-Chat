import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainAppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const MainAppDrawer({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 2,
      child: Column(
        children: [
          _buildDrawerHeader(context),
          _buildNavigation(context),
          const Spacer(),
          _buildBottomOptions(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF295BFF), Color(0xFF9B40D1)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                radius: 30,
                child: const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage('assets/images/login_head.png'),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Chat Bot',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'user@example.com',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.go('/chat/detail/new');
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Chat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(150, 36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(BuildContext context) {
    final List<Map<String, dynamic>> tabs = [
      {
        'title': 'Chat',
        'icon': Icons.chat_bubble_outline,
        'selectedIcon': Icons.chat_bubble,
        'color': const Color(0xFF6A3DE8),
      },
      {
        'title': 'AI Bots',
        'icon': Icons.smart_toy_outlined,
        'selectedIcon': Icons.smart_toy,
        'color': const Color(0xFF9B40D1),
      },
      {
        'title': 'History',
        'icon': Icons.history_outlined,
        'selectedIcon': Icons.history,
        'color': const Color(0xFF295BFF),
      },
      {
        'title': 'Profile',
        'icon': Icons.person_outline,
        'selectedIcon': Icons.person,
        'color': const Color(0xFF315BFF),
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tabs.length,
      itemBuilder: (context, index) {
        final tab = tabs[index];
        final isSelected = currentIndex == index;

        return ListTile(
          leading: Icon(
            isSelected ? tab['selectedIcon'] : tab['icon'],
            color: isSelected ? tab['color'] : Colors.grey,
          ),
          title: Text(
            tab['title'],
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? tab['color'] : Colors.black87,
            ),
          ),
          tileColor: isSelected ? tab['color'].withOpacity(0.1) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          onTap: () {
            onTabSelected(index);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildBottomOptions(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to settings
            onTabSelected(4); // Assuming there's a settings tab at index 4
          },
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Help & Support'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to help
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            Navigator.pop(context);
            context.go('/login');
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
