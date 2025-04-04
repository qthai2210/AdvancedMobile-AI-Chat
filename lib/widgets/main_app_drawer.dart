import 'package:aichatbot/screens/bot_management/bot_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/screens/knowledge_management/knowledge_management_screen.dart';
import 'package:aichatbot/screens/prompts/prompts_screen.dart';
import 'package:aichatbot/blocs/auth/auth_bloc.dart';
import 'package:aichatbot/blocs/auth/auth_event.dart';
import 'package:aichatbot/blocs/auth/auth_state.dart';

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
        'title': 'Knowledge Base',
        'icon': Icons.menu_book_outlined,
        'selectedIcon': Icons.menu_book,
        'color': const Color(0xFF0F9D58),
      },
      {
        'title': 'Prompts',
        'icon': Icons.psychology_outlined,
        'selectedIcon': Icons.psychology,
        'color': const Color(0xFFFF9800),
      },
      {
        'title': 'Email Composer',
        'icon': Icons.email_outlined,
        'selectedIcon': Icons.email,
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
            if (tab['title'] == 'Knowledge Base') {
              Navigator.pop(context);
              // Navigate directly to Knowledge Management Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KnowledgeManagementScreen(),
                ),
              );
            } else if (tab['title'] == 'Prompts') {
              Navigator.pop(context);
              // Navigate to Prompts Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PromptsScreen(),
                ),
              );
            } else if (tab['title'] == 'AI Bots') {
              Navigator.pop(context);
              // Navigate to AI Bots Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BotListScreen(),
                ),
              );
            } else {
              Navigator.pop(context);
              onTabSelected(index);
            }
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
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) {
            print(
                "Previous status: ${previous.status}, Current status: ${current.status}");
            print(
                "Previous user: ${previous.user != null}, Current user: ${current.user != null}");

            // Simplify the condition - listen for any state changes
            return true;
          },
          listener: (context, state) {
            print("Listener triggered with Status: ${state.status}");
            print("User is null: ${state.user == null}");

            if (state.status == AuthStatus.failure) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Logout failed'),
                ),
              );
            }

            // If user is null, navigate to login screen regardless of state
            if (state.user == null) {
              print("User is null, navigating to login");
              // Use a longer delay to ensure UI updates
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  context.go('/login');
                }
              });
            }
          },
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Close drawer
              Navigator.pop(context);

              // Show loading message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logging out...'),
                  duration: Duration(seconds: 2),
                ),
              );

              // Gửi sự kiện logout với context để có thể chuyển hướng
              context.read<AuthBloc>().add(LogoutRequested(context: context));
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Close the drawer
    Navigator.pop(context);

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logging out...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Dispatch logout event to AuthBloc
    context.read<AuthBloc>().add(LogoutRequested());

    // Add a delay to ensure the API call has time to complete
    await Future.delayed(const Duration(seconds: 2));

    // Ensure we're still mounted before navigation
    if (context.mounted) {
      print("Forcing navigation to login page");
      context.go('/login');
    }
  }
}
