import 'package:aichatbot/core/di/core_injection.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/models/ai_bot_model.dart';
import 'package:aichatbot/models/ai_agent_model.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';
import 'package:aichatbot/presentation/bloc/ai_email/ai_email_bloc.dart';
import 'package:aichatbot/presentation/bloc/email_reply_suggestion/email_reply_suggestion_bloc.dart';
import 'package:aichatbot/presentation/screens/assistant/create_assistant_screen.dart';
import 'package:aichatbot/presentation/screens/email_reply_suggestion_demo_screen.dart';
import 'package:aichatbot/presentation/screens/email_reply_suggestion_screen.dart';
import 'package:aichatbot/presentation/screens/purchase_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/screens/ai_email_screen.dart';
import 'package:aichatbot/screens/bot_management/bot_list_screen.dart';
import 'package:aichatbot/screens/bot_management/bot_edit_screen.dart';
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
import 'package:aichatbot/screens/welcome_screen.dart';
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
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/new_user_home',
        name: 'newUserHome',
        builder: (context, state) => const NewUserHomeScreen(),
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
        path: '/bot_management/:botId/edit',
        name: 'editAssistant',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return BotEditScreen(
            bot: extras['bot'] as AIBot,
            assistantModel: extras['assistantModel'] as AssistantModel,
          );
        },
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

          // Extract parameters from extra map
          String? initial;
          bool? toEnd;
          AIAgent? agent;

          if (extra is Map<String, dynamic>) {
            initial = extra['initialPrompt'] as String?;
            toEnd = extra['setCursorToEnd'] as bool?;
            if (extra.containsKey('initialAgent')) {
              agent = extra['initialAgent'] as AIAgent?;
            }
          }

          return ChatDetailScreen(
            isNewChat: isNew,
            threadId: isNew ? null : threadId,
            initialPrompt: initial,
            setCursorToEnd: toEnd ?? false,
            initialAgent: agent,
          );
        },
      ),
      GoRoute(
        path: '/prompts/private',
        name: 'privatePrompts',
        builder: (context, state) => const PrivatePromptsScreen(),
      ), // Route for email reply suggestions
      GoRoute(
        path: '/email/reply-suggestions',
        name: 'emailReplySuggestions',
        builder: (context, state) {
          if (state.extra == null) {
            return const Center(child: Text('No email data provided'));
          }

          final params = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (_) => sl<EmailReplySuggestionBloc>(),
            child: EmailReplySuggestionScreen(
              email: params['email'] as String,
              subject: params['subject'] as String,
              sender: params['sender'] as String,
              receiver: params['receiver'] as String,
              language: params['language'] as String,
            ),
          );
        },
      ),
      // Route for email reply suggestion demo (with example Vietnamese email)
      GoRoute(
        path: '/email/reply-suggestions-demo',
        name: 'emailReplySuggestionsDemo',
        builder: (context, state) => const EmailReplySuggestionScreen(
          email: 'example@example.com',
          subject: 'Test Subject',
          sender: 'Sender Name',
          receiver: 'Receiver Name',
          language: 'vietnamese',
        ),
      ),
      // Route for AI Email generation
      GoRoute(
        path: '/email/ai-generate',
        name: 'aiEmailGenerate',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AiEmailBloc>(),
          child: const AiEmailScreen(),
        ),
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
