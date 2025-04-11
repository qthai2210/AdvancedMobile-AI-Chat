import 'package:aichatbot/data/datasources/remote/conversation_api_service.dart';
import 'package:aichatbot/data/repositories/conversation_repository_impl.dart';
import 'package:aichatbot/domain/repositories/conversation_repository.dart';
import 'package:aichatbot/domain/usecases/chat/get_conversations_usecase.dart';
import 'package:aichatbot/presentation/bloc/conversation/conversation_bloc.dart';
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
    ),
  );
  sl.registerLazySingleton(
    () => ConversationBloc(
      getConversationsUsecase: sl(),
    ),
  );
  // sl.registerLazySingleton(
  //   () => ChatBloc(
  //     sendMessageUseCase: sl(),
  //   ),
  // );

  // Use cases
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => GetPromptsUsecase(sl()));
  sl.registerLazySingleton(() => CreatePromptUsecase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetConversationsUsecase(sl()));
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
  // Core
  sl.registerLazySingleton(() => ApiService());

  // Data sources
  sl.registerLazySingleton(
    () => AuthApiService(),
  );
  sl.registerLazySingleton(
    () => PromptApiService(),
  );
  sl.registerLazySingleton(
    () => ChatApiService(),
  );
  sl.registerLazySingleton(
    () => ConversationApiService(),
  );

  // External
  sl.registerLazySingleton(() => Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      )));
}
