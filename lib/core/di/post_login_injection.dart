import 'package:aichatbot/core/di/core_injection.dart' show sl;
import 'package:aichatbot/core/di/email_reply_suggestion_injection.dart';
import 'package:aichatbot/core/di/ai_email_injection.dart';
import 'package:aichatbot/core/di/subscription_injection.dart';
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
import 'package:aichatbot/domain/usecases/knowledge/update_knowledge_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/attach_file_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/attach_multiple_local_file_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/delete_datasource_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/fetch_knowledge_units_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_confluence_file_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_google_drive_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_local_file_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_raw_file_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_slack_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_web_use_case.dart';
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
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_bloc.dart';
import 'package:aichatbot/presentation/bloc/file_upload/file_upload_bloc.dart';
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
  // Register each service only if it's not already registered
  if (!sl.isRegistered<AssistantApiService>()) {
    sl.registerLazySingleton(() => AssistantApiService());
  }

  if (!sl.isRegistered<ChatApiService>()) {
    sl.registerLazySingleton(() => ChatApiService());
  }

  if (!sl.isRegistered<ConversationApiService>()) {
    sl.registerLazySingleton(() => ConversationApiService());
  }

  if (!sl.isRegistered<KnowledgeApiService>()) {
    sl.registerLazySingleton(() => KnowledgeApiService());
  }
  if (!sl.isRegistered<PromptApiService>()) {
    sl.registerLazySingleton(() => PromptApiService());
  }
  // Register email reply suggestion dependencies
  registerEmailReplySuggestionDependencies();
  // Register AI email generation dependencies
  registerAiEmailDependencies();
  // Register subscription dependencies
  registerSubscriptionDependencies();

  // Repositories
  if (!sl.isRegistered<AssistantRepository>()) {
    sl.registerLazySingleton<AssistantRepository>(
      () => AssistantRepositoryImpl(assistantApiService: sl()),
    );
  }

  if (!sl.isRegistered<ChatRepository>()) {
    sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(chatApiService: sl()),
    );
  }

  if (!sl.isRegistered<ConversationRepository>()) {
    sl.registerLazySingleton<ConversationRepository>(
      () => ConversationRepositoryImpl(conversationApiService: sl()),
    );
  }

  if (!sl.isRegistered<KnowledgeRepository>()) {
    sl.registerLazySingleton<KnowledgeRepository>(
      () => KnowledgeRepositoryImpl(knowledgeApiService: sl()),
    );
  }

  if (!sl.isRegistered<PromptRepository>()) {
    sl.registerLazySingleton<PromptRepository>(
      () => PromptRepositoryImpl(promptApiService: sl()),
    );
  }
  // Use cases - Only register if not already registered
  // Prompt use cases
  if (!sl.isRegistered<GetPromptsUsecase>())
    sl.registerLazySingleton(() => GetPromptsUsecase(sl()));

  if (!sl.isRegistered<CreatePromptUsecase>())
    sl.registerLazySingleton(() => CreatePromptUsecase(sl()));

  if (!sl.isRegistered<AddFavoriteUsecase>())
    sl.registerLazySingleton(() => AddFavoriteUsecase(sl()));

  if (!sl.isRegistered<RemoveFavoriteUsecase>())
    sl.registerLazySingleton(() => RemoveFavoriteUsecase(sl()));

  if (!sl.isRegistered<UpdatePromptUsecase>())
    sl.registerLazySingleton(() => UpdatePromptUsecase(sl()));

  if (!sl.isRegistered<DeletePromptUsecase>())
    sl.registerLazySingleton(() => DeletePromptUsecase(sl()));

  // Chat use cases
  if (!sl.isRegistered<SendMessageUseCase>())
    sl.registerLazySingleton(() => SendMessageUseCase(sl()));

  if (!sl.isRegistered<SendCustomBotMessageUseCase>())
    sl.registerLazySingleton(() => SendCustomBotMessageUseCase(sl()));

  // Conversation use cases
  if (!sl.isRegistered<GetConversationsUsecase>())
    sl.registerLazySingleton(() => GetConversationsUsecase(sl()));

  if (!sl.isRegistered<GetConversationHistoryUsecase>())
    sl.registerLazySingleton(() => GetConversationHistoryUsecase(sl()));

  // Assistant use cases
  if (!sl.isRegistered<GetAssistantsUseCase>())
    sl.registerLazySingleton(() => GetAssistantsUseCase(sl()));

  if (!sl.isRegistered<CreateAssistantUseCase>())
    sl.registerLazySingleton(() => CreateAssistantUseCase(sl()));

  if (!sl.isRegistered<UpdateAssistantUseCase>())
    sl.registerLazySingleton(() => UpdateAssistantUseCase(sl()));

  if (!sl.isRegistered<DeleteAssistantUseCase>())
    sl.registerLazySingleton(() => DeleteAssistantUseCase(sl()));

  // Knowledge use cases
  if (!sl.isRegistered<GetKnowledgesUseCase>())
    sl.registerLazySingleton(() => GetKnowledgesUseCase(sl()));

  if (!sl.isRegistered<CreateKnowledgeUseCase>())
    sl.registerLazySingleton(() => CreateKnowledgeUseCase(sl()));

  if (!sl.isRegistered<DeleteKnowledgeUseCase>())
    sl.registerLazySingleton(() => DeleteKnowledgeUseCase(sl()));

  if (!sl.isRegistered<UpdateKnowledgeUseCase>())
    sl.registerLazySingleton(() => UpdateKnowledgeUseCase(sl()));

  if (!sl.isRegistered<FetchKnowledgeUnitsUseCase>())
    sl.registerLazySingleton(
        () => FetchKnowledgeUnitsUseCase(sl<KnowledgeRepository>()));

  if (!sl.isRegistered<DeleteDatasourceUseCase>())
    sl.registerLazySingleton(
        () => DeleteDatasourceUseCase(sl<KnowledgeRepository>()));

  if (!sl.isRegistered<UploadLocalFileUseCase>())
    sl.registerLazySingleton(() =>
        UploadLocalFileUseCase(fileRepository: sl<KnowledgeRepository>()));

  if (!sl.isRegistered<UploadGoogleDriveFileUseCase>())
    sl.registerLazySingleton(
        () => UploadGoogleDriveFileUseCase(sl<KnowledgeRepository>()));

  if (!sl.isRegistered<UploadSlackFileUseCase>())
    sl.registerLazySingleton(
        () => UploadSlackFileUseCase(sl<KnowledgeRepository>()));

  if (!sl.isRegistered<UploadConfluenceFileUseCase>())
    sl.registerLazySingleton(
        () => UploadConfluenceFileUseCase(sl<KnowledgeRepository>()));

  if (!sl.isRegistered<UploadWebUseCase>())
    sl.registerLazySingleton(() => UploadWebUseCase(sl<KnowledgeRepository>()));

  if (!sl.isRegistered<UploadRawFileUseCase>())
    sl.registerLazySingleton(
        () => UploadRawFileUseCase(sl<KnowledgeRepository>()));

  if (!sl.isRegistered<AttachFileToKBUseCase>())
    sl.registerLazySingleton(
        () => AttachFileToKBUseCase(sl<KnowledgeRepository>()));

  if (!sl.isRegistered<AttachMultipleLocalFilesUseCase>())
    sl.registerLazySingleton(
        () => AttachMultipleLocalFilesUseCase(sl<KnowledgeRepository>()));

  // 1) Register các UseCase cho file-upload
  if (!sl.isRegistered<UploadRawFileUseCase>()) {
    sl.registerLazySingleton<UploadRawFileUseCase>(
      () => UploadRawFileUseCase(sl<KnowledgeRepository>()),
    );
  }
  if (!sl.isRegistered<AttachMultipleLocalFilesUseCase>()) {
    sl.registerLazySingleton<AttachMultipleLocalFilesUseCase>(
      () => AttachMultipleLocalFilesUseCase(sl<KnowledgeRepository>()),
    );
  }
  if (!sl.isRegistered<UploadSlackFileUseCase>()) {
    sl.registerLazySingleton<UploadSlackFileUseCase>(
      () => UploadSlackFileUseCase(sl<KnowledgeRepository>()),
    );
  }
  if (!sl.isRegistered<UploadWebUseCase>()) {
    sl.registerLazySingleton<UploadWebUseCase>(
      () => UploadWebUseCase(sl<KnowledgeRepository>()),
    );
  }

  // 2) Register FileUploadBloc
  if (!sl.isRegistered<FileUploadBloc>()) {
    sl.registerFactory<FileUploadBloc>(
      () => FileUploadBloc(
        sl<UploadRawFileUseCase>(),
        sl<UploadSlackFileUseCase>(),
        sl<UploadWebUseCase>(),
        sl<AttachMultipleLocalFilesUseCase>(),
      ),
    );
  }

  // Blocs - Only register if not already registered
  if (!sl.isRegistered<PromptBloc>()) {
    sl.registerLazySingleton(() => PromptBloc(
          getPromptsUsecase: sl(),
          createPromptUsecase: sl(),
          addFavoriteUsecase: sl(),
          removeFavoriteUsecase: sl(),
          updatePromptUsecase: sl(),
          deletePromptUsecase: sl(),
        ));
  }

  if (!sl.isRegistered<ConversationBloc>()) {
    sl.registerLazySingleton(() => ConversationBloc(
          getConversationsUsecase: sl(),
          getConversationHistoryUsecase: sl(),
        ));
  }

  if (!sl.isRegistered<ChatBloc>()) {
    sl.registerLazySingleton(() => ChatBloc(
          sendMessageUseCase: sl(),
          sendCustomBotMessageUseCase: sl(),
        ));
  }

  if (!sl.isRegistered<BotBloc>()) {
    sl.registerLazySingleton(() => BotBloc(
          getAssistantsUseCase: sl(),
          createAssistantUseCase: sl(),
          updateAssistantUseCase: sl(),
          deleteAssistantUseCase: sl(),
        ));
  }

  if (!sl.isRegistered<KnowledgeBloc>()) {
    sl.registerLazySingleton(() => KnowledgeBloc(
          getKnowledgesUseCase: sl(),
          createKnowledgeUseCase: sl(),
          deleteKnowledgeUseCase: sl(),
          updateKnowledgeUseCase: sl(),
        ));
  }

  if (!sl.isRegistered<KnowledgeUnitBloc>()) {
    sl.registerLazySingleton(() => KnowledgeUnitBloc(
          fetchKnowledgeUnitsUseCase: sl<FetchKnowledgeUnitsUseCase>(),
          deleteDatasourceUseCase: sl<DeleteDatasourceUseCase>(),
        ));
  }

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
    if (sl.isRegistered<UpdateKnowledgeUseCase>())
      sl.resetLazySingleton<UpdateKnowledgeUseCase>();
    if (sl.isRegistered<FetchKnowledgeUnitsUseCase>())
      sl.resetLazySingleton<FetchKnowledgeUnitsUseCase>();
    if (sl.isRegistered<DeleteDatasourceUseCase>())
      sl.resetLazySingleton<DeleteDatasourceUseCase>();
    if (sl.isRegistered<UploadLocalFileUseCase>())
      sl.resetLazySingleton<UploadLocalFileUseCase>();
    if (sl.isRegistered<UploadGoogleDriveFileUseCase>())
      sl.resetLazySingleton<UploadGoogleDriveFileUseCase>();
    if (sl.isRegistered<UploadSlackFileUseCase>())
      sl.resetLazySingleton<UploadSlackFileUseCase>();
    if (sl.isRegistered<UploadConfluenceFileUseCase>())
      sl.resetLazySingleton<UploadConfluenceFileUseCase>();
    if (sl.isRegistered<UploadWebUseCase>())
      sl.resetLazySingleton<UploadWebUseCase>();
    if (sl.isRegistered<FetchKnowledgeUnitsUseCase>())
      sl.resetLazySingleton<FetchKnowledgeUnitsUseCase>();
    if (sl.isRegistered<DeleteDatasourceUseCase>())
      sl.resetLazySingleton<DeleteDatasourceUseCase>();
    if (sl.isRegistered<UploadRawFileUseCase>())
      sl.resetLazySingleton<UploadRawFileUseCase>();
    if (sl.isRegistered<AttachFileToKBUseCase>())
      sl.resetLazySingleton<AttachFileToKBUseCase>();
    if (sl.isRegistered<AttachMultipleLocalFilesUseCase>())
      sl.resetLazySingleton<AttachMultipleLocalFilesUseCase>();

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

    // Reset API Services last    // Reset API Services using resetLazySingleton instead of unregister
    try {
      if (sl.isRegistered<AssistantApiService>()) {
        sl.resetLazySingleton<AssistantApiService>();
      }
    } catch (e) {
      AppLogger.e('Error resetting AssistantApiService: $e');
    }

    try {
      if (sl.isRegistered<ChatApiService>()) {
        sl.resetLazySingleton<ChatApiService>();
      }
    } catch (e) {
      AppLogger.e('Error resetting ChatApiService: $e');
    }

    try {
      if (sl.isRegistered<ConversationApiService>()) {
        sl.resetLazySingleton<ConversationApiService>();
      }
    } catch (e) {
      AppLogger.e('Error resetting ConversationApiService: $e');
    }

    try {
      if (sl.isRegistered<KnowledgeApiService>()) {
        sl.resetLazySingleton<KnowledgeApiService>();
      }
    } catch (e) {
      AppLogger.e('Error resetting KnowledgeApiService: $e');
    }

    try {
      if (sl.isRegistered<PromptApiService>()) {
        sl.resetLazySingleton<PromptApiService>();
      }
    } catch (e) {
      AppLogger.e('Error resetting PromptApiService: $e');
    }

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
