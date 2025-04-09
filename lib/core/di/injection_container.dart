import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
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
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(
    () => AuthBloc(
      loginUsecase: sl(),
      registerUsecase: sl(),
      logoutUsecase: sl(),
    ),
  );

  sl.registerFactory(
    () => PromptBloc(
      getPromptsUsecase: sl(),
      createPromptUsecase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => GetPromptsUsecase(sl()));
  sl.registerLazySingleton(() => CreatePromptUsecase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authApiService: sl()),
  );
  sl.registerLazySingleton<PromptRepository>(
    () => PromptRepositoryImpl(promptApiService: sl()),
  );

  // Data sources
  sl.registerLazySingleton(
    () => AuthApiService(client: sl()),
  );
  sl.registerLazySingleton(
    () => PromptApiService(client: sl()),
  );

  // External
  sl.registerLazySingleton(() => http.Client());
}
