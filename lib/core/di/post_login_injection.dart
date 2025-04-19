import 'package:aichatbot/core/di/core_injection.dart' show sl;
import 'package:aichatbot/data/datasources/remote/assistant_api_service.dart';
import 'package:aichatbot/data/datasources/remote/chat_api_service.dart';
import 'package:aichatbot/data/datasources/remote/conversation_api_service.dart';
import 'package:aichatbot/data/datasources/remote/knowledge_api_service.dart';
import 'package:aichatbot/data/datasources/remote/prompt_api_service.dart';
import 'package:aichatbot/data/repositories/assistant_repository_impl.dart';
import 'package:aichatbot/data/repositories/chat_repository_impl.dart';
import 'package:aichatbot/data/repositories/conversation_repository_impl.dart';
import 'package:aichatbot/data/repositories/knowledge_repository_impl.dart';
import 'package:aichatbot/data/repositories/prompt_repository_impl.dart';
import 'package:aichatbot/domain/repositories/assistant_repository.dart';
import 'package:aichatbot/domain/repositories/chat_repository.dart';
import 'package:aichatbot/domain/repositories/conversation_repository.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';
import 'package:aichatbot/domain/repositories/prompt_repository.dart';
import 'package:aichatbot/domain/usecases/assistant/create_assistant_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/delete_assistant_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/get_assistants_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/update_assistant_usecase.dart';
import 'package:aichatbot/domain/usecases/chat/get_conversation_history_usecase.dart';
import 'package:aichatbot/domain/usecases/chat/get_conversations_usecase.dart';
import 'package:aichatbot/domain/usecases/chat/send_custom_bot_message_usecase.dart';
import 'package:aichatbot/domain/usecases/chat/send_message_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge/create_knowledge_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge/delete_knowledge_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge/get_knowledges_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/add_favorite_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/create_prompt_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/delete_prompt_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/get_prompts_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/remove_favorite_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/update_prompt_usecase.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/chat/chat_bloc.dart';
import 'package:aichatbot/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/utils/logger.dart';

// Flag to track if post-login services have been initialized
bool _postLoginServicesInitialized = false;

/// Initialize all post-login services
/// Call this function after successful login
Future<void> initPostLoginServices() async {
  // Avoid duplicate initialization
  if (_postLoginServicesInitialized) {
    AppLogger.i('Post-login services already initialized');
    return;
  }

  AppLogger.i('Initializing post-login services...');

  // API Services (initialize on demand after login)
  sl.registerLazySingleton(() => AssistantApiService());
  sl.registerLazySingleton(() => ChatApiService());
  sl.registerLazySingleton(() => ConversationApiService());
  sl.registerLazySingleton(() => KnowledgeApiService());
  sl.registerLazySingleton(() => PromptApiService());

  // Repositories
  sl.registerLazySingleton<AssistantRepository>(
    () => AssistantRepositoryImpl(assistantApiService: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(chatApiService: sl()),
  );
  sl.registerLazySingleton<ConversationRepository>(
    () => ConversationRepositoryImpl(conversationApiService: sl()),
  );
  sl.registerLazySingleton<KnowledgeRepository>(
    () => KnowledgeRepositoryImpl(knowledgeApiService: sl()),
  );
  sl.registerLazySingleton<PromptRepository>(
    () => PromptRepositoryImpl(promptApiService: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPromptsUsecase(sl()));
  sl.registerLazySingleton(() => CreatePromptUsecase(sl()));
  sl.registerLazySingleton(() => AddFavoriteUsecase(sl()));
  sl.registerLazySingleton(() => RemoveFavoriteUsecase(sl()));
  sl.registerLazySingleton(() => UpdatePromptUsecase(sl()));
  sl.registerLazySingleton(() => DeletePromptUsecase(sl()));

  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => SendCustomBotMessageUseCase(sl()));

  sl.registerLazySingleton(() => GetConversationsUsecase(sl()));
  sl.registerLazySingleton(() => GetConversationHistoryUsecase(sl()));

  sl.registerLazySingleton(() => GetAssistantsUseCase(sl()));
  sl.registerLazySingleton(() => CreateAssistantUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAssistantUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAssistantUseCase(sl()));

  sl.registerLazySingleton(() => GetKnowledgesUseCase(sl()));
  sl.registerLazySingleton(() => CreateKnowledgeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteKnowledgeUseCase(sl()));

  // Blocs
  sl.registerLazySingleton(() => PromptBloc(
        getPromptsUsecase: sl(),
        createPromptUsecase: sl(),
        addFavoriteUsecase: sl(),
        removeFavoriteUsecase: sl(),
        updatePromptUsecase: sl(),
        deletePromptUsecase: sl(),
      ));

  sl.registerLazySingleton(() => ConversationBloc(
        getConversationsUsecase: sl(),
        getConversationHistoryUsecase: sl(),
      ));

  sl.registerLazySingleton(() => ChatBloc(
        sendMessageUseCase: sl(),
        sendCustomBotMessageUseCase: sl(),
      ));

  sl.registerLazySingleton(() => BotBloc(
        getAssistantsUseCase: sl(),
        createAssistantUseCase: sl(),
        updateAssistantUseCase: sl(),
        deleteAssistantUseCase: sl(),
      ));

  sl.registerLazySingleton(() => KnowledgeBloc(
        getKnowledgesUseCase: sl(),
        createKnowledgeUseCase: sl(),
        deleteKnowledgeUseCase: sl(),
      ));

  _postLoginServicesInitialized = true;
  AppLogger.i('Post-login services initialized successfully');
}

/// Call this function at logout to reset post-login services
Future<void> resetPostLoginServices() async {
  if (!_postLoginServicesInitialized) {
    AppLogger.i('Post-login services not initialized, nothing to reset');
    return;
  }

  AppLogger.i('Resetting post-login services...');

  try {
    // Reset Blocs first to prevent usage during cleanup
    if (sl.isRegistered<PromptBloc>()) sl.resetLazySingleton<PromptBloc>();
    if (sl.isRegistered<ConversationBloc>())
      sl.resetLazySingleton<ConversationBloc>();
    if (sl.isRegistered<ChatBloc>()) sl.resetLazySingleton<ChatBloc>();
    if (sl.isRegistered<BotBloc>()) sl.resetLazySingleton<BotBloc>();
    if (sl.isRegistered<KnowledgeBloc>())
      sl.resetLazySingleton<KnowledgeBloc>();

    // Reset Use cases
    if (sl.isRegistered<GetPromptsUsecase>())
      sl.resetLazySingleton<GetPromptsUsecase>();
    if (sl.isRegistered<CreatePromptUsecase>())
      sl.resetLazySingleton<CreatePromptUsecase>();
    if (sl.isRegistered<AddFavoriteUsecase>())
      sl.resetLazySingleton<AddFavoriteUsecase>();
    if (sl.isRegistered<RemoveFavoriteUsecase>())
      sl.resetLazySingleton<RemoveFavoriteUsecase>();
    if (sl.isRegistered<UpdatePromptUsecase>())
      sl.resetLazySingleton<UpdatePromptUsecase>();
    if (sl.isRegistered<DeletePromptUsecase>())
      sl.resetLazySingleton<DeletePromptUsecase>();
    if (sl.isRegistered<SendMessageUseCase>())
      sl.resetLazySingleton<SendMessageUseCase>();
    if (sl.isRegistered<SendCustomBotMessageUseCase>())
      sl.resetLazySingleton<SendCustomBotMessageUseCase>();
    if (sl.isRegistered<GetConversationsUsecase>())
      sl.resetLazySingleton<GetConversationsUsecase>();
    if (sl.isRegistered<GetConversationHistoryUsecase>())
      sl.resetLazySingleton<GetConversationHistoryUsecase>();
    if (sl.isRegistered<GetAssistantsUseCase>())
      sl.resetLazySingleton<GetAssistantsUseCase>();
    if (sl.isRegistered<CreateAssistantUseCase>())
      sl.resetLazySingleton<CreateAssistantUseCase>();
    if (sl.isRegistered<UpdateAssistantUseCase>())
      sl.resetLazySingleton<UpdateAssistantUseCase>();
    if (sl.isRegistered<DeleteAssistantUseCase>())
      sl.resetLazySingleton<DeleteAssistantUseCase>();
    if (sl.isRegistered<GetKnowledgesUseCase>())
      sl.resetLazySingleton<GetKnowledgesUseCase>();
    if (sl.isRegistered<CreateKnowledgeUseCase>())
      sl.resetLazySingleton<CreateKnowledgeUseCase>();
    if (sl.isRegistered<DeleteKnowledgeUseCase>())
      sl.resetLazySingleton<DeleteKnowledgeUseCase>();

    // Reset Repositories
    if (sl.isRegistered<AssistantRepository>())
      sl.resetLazySingleton<AssistantRepository>();
    if (sl.isRegistered<ChatRepository>())
      sl.resetLazySingleton<ChatRepository>();
    if (sl.isRegistered<ConversationRepository>())
      sl.resetLazySingleton<ConversationRepository>();
    if (sl.isRegistered<KnowledgeRepository>())
      sl.resetLazySingleton<KnowledgeRepository>();
    if (sl.isRegistered<PromptRepository>())
      sl.resetLazySingleton<PromptRepository>();

    // Reset API Services last
    if (sl.isRegistered<AssistantApiService>())
      sl.resetLazySingleton<AssistantApiService>();
    if (sl.isRegistered<ChatApiService>())
      sl.resetLazySingleton<ChatApiService>();
    if (sl.isRegistered<ConversationApiService>())
      sl.resetLazySingleton<ConversationApiService>();
    if (sl.isRegistered<KnowledgeApiService>())
      sl.resetLazySingleton<KnowledgeApiService>();
    if (sl.isRegistered<PromptApiService>())
      sl.resetLazySingleton<PromptApiService>();

    // Mark services as uninitialized
    _postLoginServicesInitialized = false;
    AppLogger.i('Post-login services reset successfully');
  } catch (e) {
    AppLogger.e('Error resetting post-login services: $e');
    // Still mark as uninitialized even if there was an error
    _postLoginServicesInitialized = false;
  }
}

/// Check if post-login services are initialized
bool get arePostLoginServicesInitialized => _postLoginServicesInitialized;
