import 'package:aichatbot/screens/bot_management/bot_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/screens/knowledge_management/knowledge_management_screen.dart';
import 'package:aichatbot/screens/prompts/prompts_screen.dart';
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
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
          const Divider(),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Settings',
            index: 4,
            isSelected: currentIndex == 4,
          ),
          _buildDrawerItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            index: 5,
            isSelected: currentIndex == 5,
          ),
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
