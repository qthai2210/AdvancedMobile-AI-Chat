import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_event.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_state.dart';

class MainAppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const MainAppDrawer({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            child: const DrawerHeader(
              decoration: BoxDecoration(
                  // No color here, as we're using the Container's color
                  ),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Chat Assistant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Powered by Jarvis AI',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Upper drawer section with main menu items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDrawerItem(
                    icon: Icons.chat,
                    title: 'Chat',
                    index: 0,
                    isSelected: currentIndex == 0,
                  ),
                  _buildDrawerItem(
                    icon: Icons.email,
                    title: 'Email Composer',
                    index: 1,
                    isSelected: currentIndex == 1,
                  ),
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: 'Profile',
                    index: 2,
                    isSelected: currentIndex == 2,
                  ),
                  _buildDrawerItem(
                    icon: Icons.lightbulb_outline,
                    title: 'Prompts',
                    index: 3,
                    isSelected: currentIndex == 3,
                  ),
                  _buildDrawerItem(
                    title: 'Bot Management',
                    icon: Icons.android,
                    index: 4,
                    isSelected: currentIndex == 4,
                  ),
                  _buildDrawerItem(
                    icon: Icons.book,
                    title: 'Knowledge Management',
                    index: 5,
                    isSelected: currentIndex == 5,
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    index: 6,
                    isSelected: currentIndex == 6,
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    index: 7,
                    isSelected: currentIndex == 7,
                  ),
                ],
              ),
            ),
          ),
          // Divider to separate the two parts
          const Divider(thickness: 1),
          // Lower drawer section with logout option
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // Only show logout if user is authenticated
              if (state.user != null) {
                return ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              context
                                  .read<AuthBloc>()
                                  .add(LogoutRequested(context: context));
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox
                  .shrink(); // Return empty widget if not authenticated
            },
          ),
          // Add a small bottom padding
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      onTap: () {
        onTabSelected(index);
      },
    );
  }
}
