import 'package:aichatbot/screens/email_composer_screen.dart';
import 'package:aichatbot/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/screens/chat_ai_screen.dart';
import 'package:aichatbot/screens/bot_management/bot_list_screen.dart';
import 'package:aichatbot/screens/knowledge_management/knowledge_management_screen.dart';
import 'package:aichatbot/screens/prompts/prompts_screen.dart';

/// Handles navigation from drawer tabs
void handleDrawerNavigation(BuildContext context, int index,
    {int currentIndex = -1}) {
  // Close the drawer first
  //Navigator.pop(context);
  debugPrint('Navigating to drawer index: $index');
  debugPrint('Current index: $currentIndex');
  // Don't navigate if we're already on the selected screen
  if (index == currentIndex) return;

  // Navigate based on the index
  switch (index) {
    case 0: // Chat
      _safeNavigate(context, '/chat/detail/new', () => const ChatAIScreen());
      break;

    case 1: // AI Bots
      _safeNavigate(context, '/bots', () => const BotListScreen());
      break;

    case 2: // Knowledge Base
      _safeNavigate(
          context, '/knowledge', () => const KnowledgeManagementScreen());
      break;

    case 3: // Prompts
      _safeNavigate(context, '/prompts', () => const PromptsScreen());
      break;

    case 4: // Email Composer (replacing History)
      _safeNavigate(context, '/email', () => const EmailComposerScreen());
      break;

    case 5: // Profile
      _safeNavigate(context, '/profile', () => const ProfileScreen());
      break;

    default:
      // Handle unknown tab index
      debugPrint('Unknown tab index: $index');
  }
}

/// Safely navigate using GoRouter with MaterialPageRoute fallback
void _safeNavigate(
    BuildContext context, String route, Widget Function() builder) {
  try {
    // First try to use GoRouter's push method which is safer than go
    context.go(route);
  } catch (e) {
    // If GoRouter fails (e.g., no routes in stack), fall back to MaterialPageRoute
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => builder()),
      );
    } catch (e) {
      // Last resort fallback
      debugPrint('Navigation error: $e');

      // Try one more time with a basic navigation approach
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => builder()),
        (route) => false,
      );
    }
  }
}
