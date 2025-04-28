import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_state.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/chat/chat_bloc.dart';
import 'package:aichatbot/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:aichatbot/presentation/bloc/file_upload/file_upload_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/router/app_router.dart';
import 'package:aichatbot/core/services/bloc_manager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/di/injection_container.dart' as di;

/// Wrapper widget that listens to auth state and provides appropriate blocs
class AuthWrapper extends StatelessWidget {
  final FirebaseAnalytics analytics;
  const AuthWrapper({
    Key? key,
    required this.analytics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState.status == AuthStatus.success;
    final blocManager = di.sl<BlocManager>();

    if (isAuthenticated) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(
              value: BlocProvider.of<AuthBloc>(context)),
          BlocProvider<PromptBloc>.value(
              value:
                  blocManager.getBloc<PromptBloc>(() => di.sl<PromptBloc>())),
          BlocProvider<ConversationBloc>.value(
              value: blocManager
                  .getBloc<ConversationBloc>(() => di.sl<ConversationBloc>())),
          BlocProvider<ChatBloc>.value(
              value: blocManager.getBloc<ChatBloc>(() => di.sl<ChatBloc>())),
          BlocProvider<BotBloc>.value(
              value: blocManager.getBloc<BotBloc>(() => di.sl<BotBloc>())),
          BlocProvider<KnowledgeBloc>.value(
              value: blocManager
                  .getBloc<KnowledgeBloc>(() => di.sl<KnowledgeBloc>())),
          BlocProvider<KnowledgeUnitBloc>.value(
              value: blocManager.getBloc<KnowledgeUnitBloc>(
                  () => di.sl<KnowledgeUnitBloc>())),
          BlocProvider<FileUploadBloc>.value(
              value: blocManager
                  .getBloc<FileUploadBloc>(() => di.sl<FileUploadBloc>())),
        ],
        child: MaterialApp.router(
          title: 'AI Chat Bot',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          // MaterialApp.router không hỗ trợ navigatorObservers ở phiên bản này
          // Nếu dùng go_router, gán observer trong router config thay vì ở đây
        ),
      );
    } else {
      return MaterialApp.router(
        title: 'AI Chat Bot',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routerConfig: AppRouter.router,
        // loại bỏ tham số không hợp lệ
      );
    }
  }
}
