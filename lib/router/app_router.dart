import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/screens/login_screen.dart';
import 'package:aichatbot/screens/register_screen.dart';
import 'package:aichatbot/screens/home_screen.dart';
import 'package:aichatbot/screens/chat_ai_screen.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

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
    ],
    // Redirect to login if not authenticated
    redirect: (context, state) {
      // You can add authentication logic here later
      // For example:
      // final isLoggedIn = AuthService.isLoggedIn;
      // if (!isLoggedIn && state.location != '/login')
      //   return '/login';
      return null;
    },
    // Error handling
    errorBuilder:
        (context, state) =>
            Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}
