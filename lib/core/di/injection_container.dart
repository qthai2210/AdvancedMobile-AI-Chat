import 'package:aichatbot/core/network/token_refresh_interceptor.dart';
import 'package:aichatbot/domain/usecases/assistant/create_assistant_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/delete_assistant_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/update_assistant_usecase.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:aichatbot/data/datasources/remote/assistant_api_service.dart';
import 'package:aichatbot/data/datasources/remote/conversation_api_service.dart';
import 'package:aichatbot/data/datasources/remote/knowledge_api_service.dart';
import 'package:aichatbot/data/repositories/assistant_repository_impl.dart';
import 'package:aichatbot/data/repositories/conversation_repository_impl.dart';
import 'package:aichatbot/data/repositories/knowledge_repository_impl.dart';
import 'package:aichatbot/domain/repositories/assistant_repository.dart';
import 'package:aichatbot/domain/repositories/conversation_repository.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';
import 'package:aichatbot/domain/usecases/assistant/get_assistants_usecase.dart';
import 'package:aichatbot/domain/usecases/chat/get_conversations_usecase.dart';
import 'package:aichatbot/domain/usecases/chat/get_conversation_history_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge/create_knowledge_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge/delete_knowledge_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge/get_knowledges_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/delete_prompt_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/update_prompt_usecase.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/chat/chat_bloc.dart';
import 'package:aichatbot/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/data/datasources/remote/auth_api_service.dart';
import 'package:aichatbot/data/datasources/remote/prompt_api_service.dart';
import 'package:aichatbot/data/repositories/auth_repository_impl.dart';
import 'package:aichatbot/data/repositories/prompt_repository_impl.dart';
import 'package:aichatbot/domain/repositories/auth_repository.dart';
import 'package:aichatbot/domain/repositories/prompt_repository.dart';
import 'package:aichatbot/domain/usecases/auth/login_usecase.dart';
import 'package:aichatbot/domain/usecases/auth/logout_usecase.dart';
import 'package:aichatbot/domain/usecases/auth/register_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/create_prompt_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/get_prompts_usecase.dart';
import 'package:aichatbot/domain/usecases/chat/send_message_usecase.dart';
import 'package:aichatbot/data/datasources/remote/chat_api_service.dart';
import 'package:aichatbot/data/repositories/chat_repository_impl.dart';
import 'package:aichatbot/domain/repositories/chat_repository.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/domain/usecases/prompt/add_favorite_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/remove_favorite_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUsecase: sl(),
      registerUsecase: sl(),
      logoutUsecase: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => PromptBloc(
      getPromptsUsecase: sl(),
      createPromptUsecase: sl(),
      addFavoriteUsecase: sl(),
      removeFavoriteUsecase: sl(),
      updatePromptUsecase: sl(),
      deletePromptUsecase: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => ConversationBloc(
      getConversationsUsecase: sl(),
      getConversationHistoryUsecase: sl(),
    ),
  );
  // Registering ChatBloc as a factory instead of a singleton
  // This ensures each ChatDetailScreen gets its own fresh instance of ChatBloc  sl.registerFactory(
  sl.registerLazySingleton(
    () => ChatBloc(
      sendMessageUseCase: sl(),
    ),
  ); // Register BotBloc as a factory to ensure fresh instance each time  sl.registerLazySingleton(
  sl.registerLazySingleton(
    () => BotBloc(
      getAssistantsUseCase: sl(),
      createAssistantUseCase: sl(),
      updateAssistantUseCase: sl(),
      deleteAssistantUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => KnowledgeBloc(
      getKnowledgesUseCase: sl(),
      createKnowledgeUseCase: sl(),
      deleteKnowledgeUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => GetPromptsUsecase(sl()));
  sl.registerLazySingleton(() => CreatePromptUsecase(sl()));
  sl.registerLazySingleton(() => AddFavoriteUsecase(sl()));
  sl.registerLazySingleton(() => RemoveFavoriteUsecase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetConversationsUsecase(sl()));
  sl.registerLazySingleton(() => GetConversationHistoryUsecase(sl()));
  sl.registerLazySingleton(() => UpdatePromptUsecase(sl()));
  sl.registerLazySingleton(() => DeletePromptUsecase(sl()));
  sl.registerLazySingleton(() => GetAssistantsUseCase(sl()));
  sl.registerLazySingleton(() => GetKnowledgesUseCase(sl()));
  sl.registerLazySingleton(() => CreateKnowledgeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteKnowledgeUseCase(sl()));
  sl.registerLazySingleton(() => CreateAssistantUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAssistantUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAssistantUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authApiService: sl()),
  );
  sl.registerLazySingleton<PromptRepository>(
    () => PromptRepositoryImpl(promptApiService: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(chatApiService: sl()),
  );
  sl.registerLazySingleton<ConversationRepository>(
    () => ConversationRepositoryImpl(conversationApiService: sl()),
  );
  sl.registerLazySingleton<AssistantRepository>(
    () => AssistantRepositoryImpl(assistantApiService: sl()),
  );
  sl.registerLazySingleton<KnowledgeRepository>(
    () => KnowledgeRepositoryImpl(knowledgeApiService: sl()),
  );

  // Core
  sl.registerLazySingleton(() => SecureStorageUtil());
  sl.registerLazySingleton(() => ApiService());

  // Data sources
  sl.registerFactory(() => AuthApiService());
  sl.registerFactory(() => PromptApiService());
  sl.registerFactory(() => AssistantApiService());
  sl.registerFactory(() => ChatApiService());
  sl.registerFactory(() => ConversationApiService());
  sl.registerFactory(() => KnowledgeApiService());

  // External
  sl.registerLazySingleton(() => Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      )));

  // After all services are registered, manually add the TokenRefreshInterceptor to avoid circular dependency
  final apiService = sl<ApiService>();
  final authApiService = sl<AuthApiService>();
  final secureStorage = sl<SecureStorageUtil>();

  final interceptor = TokenRefreshInterceptor(
    dio: apiService.dio,
    authApiService: authApiService,
    secureStorage: secureStorage,
  );

  apiService.addTokenRefreshInterceptor(interceptor);
}
