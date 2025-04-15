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
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
        ),
        BlocProvider<PromptBloc>(
          create: (context) => di.sl<PromptBloc>(),
        ),
        BlocProvider<ConversationBloc>(
          create: (context) => di.sl<ConversationBloc>(),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => di.sl<ChatBloc>(),
        ),
        BlocProvider<BotBloc>(
          create: (context) => di.sl<BotBloc>(),
        ),
        BlocProvider(create: (context) => di.sl<KnowledgeBloc>()),
      ],
      child: MaterialApp.router(
        title: 'AI Chat Bot',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
