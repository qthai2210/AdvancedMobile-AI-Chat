import 'package:aichatbot/presentation/screens/assistant/create_assistant_screen.dart';
import 'package:aichatbot/presentation/screens/assistant/create_assistant_screen.dart';
import 'package:aichatbot/presentation/screens/assistant/create_assistant_screen.dart';
import 'package:aichatbot/screens/bot_management/bot_list_screen.dart';
import 'package:aichatbot/screens/email_composer_screen.dart';
import 'package:aichatbot/screens/knowledge_management/knowledge_management_screen.dart';
import 'package:aichatbot/screens/profile_screen.dart';
import 'package:aichatbot/screens/prompts/prompts_screen.dart';
import 'package:aichatbot/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/screens/login_screen.dart';
import 'package:aichatbot/screens/register_screen.dart';
import 'package:aichatbot/screens/home_screen.dart';
import 'package:aichatbot/screens/chat_ai_screen.dart';
import 'package:aichatbot/screens/chat_detail_screen.dart';
import 'package:aichatbot/screens/prompts/create_prompt_screen.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // Add splash screen route
      // Make sure to import SplashScreen at the top of the file
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
              onPressed: () => context.go('/chat/detail/new'),
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
        return '/chat/detail/new';
      }
      return null;
    },
  );
}


/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/countries/country_bloc.dart';
import '../../bloc/news/news_bloc.dart';
import '../../data/model/news_list/news_list_main.dart';
import '../../ui/country_list/country_list_center_screen.dart';
import '../../ui/country_list/country_list_screen.dart';
import '../../ui/news_detail/news_detail_screen.dart';
import '../../ui/news_detail/news_detail_slider_screen.dart';
import '../../ui/news_home/news_list_pagination_screen.dart';
import '../../ui/news_home/news_list_screen.dart';

class RouteGenerator {

  Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case NewsListScreen.id:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<NewsBloc>.value(
            value: NewsBloc(),
            child: const NewsListScreen(),
          ),
        );

      case NewsDetailSliderScreen.id:
        return MaterialPageRoute(
          builder: (context) {
            return NewsDetailSliderScreen(newsList: args as List<Article>);
          },
        );

      case NewsDetailScreen.id:
        return MaterialPageRoute(
          builder: (context) {
            return NewsDetailScreen(articleData: args as Article);
          },
        );

      case CountryListScreen.id:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<CountryBloc>.value(
            value: CountryBloc(),
            child: const CountryListScreen(),
          ),
        );

      case CountryListCenterScreen.id:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<CountryBloc>.value(
            value: CountryBloc(),
            child: CountryListCenterScreen(selectedCountry: args as String),
          ),
        );

      case NewsListPaginationScreen.id:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<NewsBloc>.value(
            value: NewsBloc(),
            child: const NewsListPaginationScreen(),
          ),
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Error while loading new page'),
        ),
      );
    });
  }
}
 */