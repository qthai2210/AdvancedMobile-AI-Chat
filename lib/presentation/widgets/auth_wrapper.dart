import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_state.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/chat/chat_bloc.dart';
import 'package:aichatbot/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/router/app_router.dart';
import 'package:aichatbot/core/services/bloc_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/di/injection_container.dart' as di;

/// Wrapper widget that listens to auth state and provides appropriate blocs
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the auth state from the bloc
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState.status == AuthStatus.success;

    // Get BlocManager instance
    final blocManager = di.sl<BlocManager>();

    // If authenticated, provide all blocs including post-login blocs
    if (isAuthenticated) {
      return MultiBlocProvider(
        providers: [
          // Re-provide AuthBloc to pass it down
          BlocProvider<AuthBloc>.value(
            value: BlocProvider.of<AuthBloc>(context),
          ),
          // Add all the post-login blocs
          BlocProvider<PromptBloc>.value(
            value: blocManager.getBloc<PromptBloc>(() => di.sl<PromptBloc>()),
          ),
          BlocProvider<ConversationBloc>.value(
            value: blocManager
                .getBloc<ConversationBloc>(() => di.sl<ConversationBloc>()),
          ),
          BlocProvider<ChatBloc>.value(
            value: blocManager.getBloc<ChatBloc>(() => di.sl<ChatBloc>()),
          ),
          BlocProvider<BotBloc>.value(
            value: blocManager.getBloc<BotBloc>(() => di.sl<BotBloc>()),
          ),
          BlocProvider<KnowledgeBloc>.value(
            value: blocManager
                .getBloc<KnowledgeBloc>(() => di.sl<KnowledgeBloc>()),
          ),
        ],
        child: MaterialApp.router(
          title: 'AI Chat Bot',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          routerConfig: AppRouter.router,
        ),
      );
    }

    // If not authenticated, provide only the MaterialApp without post-login blocs
    return MaterialApp.router(
      title: 'AI Chat Bot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
