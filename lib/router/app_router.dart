import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/screens/login_screen.dart';
import 'package:aichatbot/screens/register_screen.dart';
import 'package:aichatbot/screens/home_screen.dart';
import 'package:aichatbot/screens/chat_ai_screen.dart';
import 'package:aichatbot/screens/chat_detail_screen.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatAIScreen(),
      ),
      // Updated route for chat detail to handle deep linking
      GoRoute(
        path: '/chat/detail/:threadId',
        name: 'chatDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final threadId = state.pathParameters['threadId'];
          final isNew = threadId == 'new';
          return ChatDetailScreen(
            isNewChat: isNew,
            threadId: isNew ? null : threadId,
          );
        },
      ),
    ],
    // Add error handler for navigation errors
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/chat'),
              child: const Text('Go to Chat Screen'),
            ),
          ],
        ),
      ),
    ),
    // Define redirect to handle empty routes
    redirect: (BuildContext context, GoRouterState state) {
      // If the app tries to navigate to an empty stack, redirect to chat
      if (state.matchedLocation.isEmpty) {
        return '/chat';
      }
      return null;
    },
  );
}
