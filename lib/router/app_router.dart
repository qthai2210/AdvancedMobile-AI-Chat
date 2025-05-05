import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';
import 'package:aichatbot/presentation/screens/assistant/create_assistant_screen.dart';
import 'package:aichatbot/presentation/screens/purchase_screen.dart';
import 'package:aichatbot/screens/bot_management/bot_list_screen.dart';
import 'package:aichatbot/screens/chat_ai_screen.dart';
import 'package:aichatbot/screens/chat_detail_screen.dart';
import 'package:aichatbot/screens/email_composer_screen.dart';
import 'package:aichatbot/screens/home_screen.dart';
import 'package:aichatbot/screens/knowledge_management/add_source_screen.dart';
import 'package:aichatbot/screens/knowledge_management/knowledge_detail_screen.dart';
import 'package:aichatbot/screens/knowledge_management/knowledge_management_screen.dart';
import 'package:aichatbot/screens/knowledge_management/update_knowledge_screen.dart';
import 'package:aichatbot/screens/login_screen.dart';
import 'package:aichatbot/screens/profile_screen.dart';
import 'package:aichatbot/screens/prompts/create_prompt_screen.dart';
import 'package:aichatbot/screens/prompts/edit_prompt_screen.dart';
import 'package:aichatbot/screens/prompts/private_prompts_screen.dart';
import 'package:aichatbot/screens/prompts/prompts_screen.dart';
import 'package:aichatbot/screens/register_screen.dart';
import 'package:aichatbot/screens/splash_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final shellNavigatorKey = GlobalKey<NavigatorState>();
  static final _analytics = FirebaseAnalytics.instance;
  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
      GoRoute(
        path: '/bot_management',
        name: 'bot_management',
        builder: (context, state) => const BotListScreen(),
      ),
      GoRoute(
        path: '/bot_management/create',
        name: 'createAssistant',
        builder: (context, state) => const CreateAssistantScreen(),
      ),
      GoRoute(
        path: '/email',
        name: 'email',
        builder: (context, state) => const EmailComposerScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      // Route for purchase screen
      GoRoute(
        path: '/purchase',
        name: 'purchase',
        builder: (context, state) => const PurchaseScreen(),
      ),
      GoRoute(
        path: '/prompts',
        name: 'prompts',
        builder: (context, state) => const PromptsScreen(),
      ),
      GoRoute(
        path: '/prompts/create',
        name: 'createPrompt',
        builder: (context, state) => const CreatePromptScreen(),
      ),
      // add knowledge route
      GoRoute(
          path: '/knowledge_management',
          name: 'knowledge_management',
          builder: (context, state) {
            return const KnowledgeManagementScreen();
          }),
      // Updated route for chat detail to handle deep linking
      GoRoute(
          path: '/knowledge/:id/detail',
          name: 'knowledgeDetail',
          builder: (context, state) {
            final kb = state.extra as KnowledgeBase;
            return KnowledgeDetailScreen(
              knowledgeBase: kb,
            );
          }),
      GoRoute(
        path: '/knowledge/:id/add_source',
        name: 'addSource',
        builder: (ctx, state) {
          final kb = state.extra as KnowledgeBase;
          return AddSourceScreen(knowledgeBase: kb);
        },
      ),
      GoRoute(
        path: '/knowledge/:id/edit',
        name: 'editKnowledge',
        builder: (ctx, state) {
          final kb = state.extra as KnowledgeBase;
          return UpdateKnowledgeScreen(knowledgeBase: kb);
        },
      ),
      GoRoute(
        path: '/prompts/:id/edit',
        name: 'editPrompt',
        builder: (ctx, state) {
          final prompt = state.extra as PromptModel;
          return EditPromptScreen(prompt: prompt);
        },
      ),
      GoRoute(
        path: '/chat/detail/:threadId',
        name: 'chatDetail',
        builder: (context, state) {
          final threadId = state.pathParameters['threadId']!;
          final isNew = threadId == 'new';
          final extra = state.extra;
          final initial = (extra is Map<String, dynamic>)
              ? extra['initialPrompt'] as String?
              : null;
          final toEnd = (extra is Map<String, dynamic>)
              ? extra['setCursorToEnd'] as bool?
              : false;
          return ChatDetailScreen(
            isNewChat: isNew,
            threadId: isNew ? null : threadId,
            initialPrompt: initial,
            setCursorToEnd: toEnd ?? false,
          );
        },
      ),
      GoRoute(
        path: '/prompts/private',
        name: 'privatePrompts',
        builder: (context, state) => const PrivatePromptsScreen(),
      ),
    ],
    // ② thêm observer ở GoRouter
    observers: [
      FirebaseAnalyticsObserver(analytics: _analytics),
    ],
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
              onPressed: () => context.go('/chat/detail/new'),
              child: const Text('Go to Chat Screen'),
            ),
          ],
        ),
      ),
    ),
    redirect: (BuildContext context, GoRouterState state) {
      // If the app tries to navigate to an empty stack, redirect to chat
      if (state.matchedLocation.isEmpty) {
        return '/chat/detail/new';
      }
      return null;
    },
    // ① thêm observer ở GoRouter
  );
}
