import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/chat/chat_bloc.dart';
import 'package:aichatbot/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/di/injection_container.dart' as di;
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/router/app_router.dart';
import 'package:aichatbot/core/services/bloc_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();
  // remove deubg banner
  // debugPaintSizeEnabled = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Get BlocManager instance
    final blocManager = di.sl<BlocManager>();

    return MultiBlocProvider(
      providers: [
        // Use BlocProvider.value to prevent automatic closing of blocs
        BlocProvider<AuthBloc>.value(
          value: blocManager.getBloc<AuthBloc>(() => di.sl<AuthBloc>()),
        ),
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
                .getBloc<KnowledgeBloc>(() => di.sl<KnowledgeBloc>())),
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
}
