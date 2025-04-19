import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/core/network/token_refresh_interceptor.dart';
import 'package:aichatbot/core/services/bloc_manager.dart';
import 'package:aichatbot/data/datasources/remote/auth_api_service.dart';
import 'package:aichatbot/data/repositories/auth_repository_impl.dart';
import 'package:aichatbot/domain/repositories/auth_repository.dart';
import 'package:aichatbot/domain/usecases/auth/login_usecase.dart';
import 'package:aichatbot/domain/usecases/auth/logout_usecase.dart';
import 'package:aichatbot/domain/usecases/auth/register_usecase.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

// Reference to the service locator
final sl = GetIt.instance;

/// Initialize only core services needed before login
Future<void> initCoreServices() async {
  AppLogger.i('Initializing core services...');

  // Register BlocManager first
  sl.registerLazySingleton(() => BlocManager());

  // Core services & utilities
  sl.registerLazySingleton(() => SecureStorageUtil());
  sl.registerLazySingleton(() => ApiService());
  sl.registerLazySingleton(() => Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      )));

  // Auth-related services (needed before login)
  sl.registerLazySingleton(() => AuthApiService());
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(authApiService: sl()));
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));

  // Auth Bloc (needed for login flow)
  sl.registerLazySingleton(() => AuthBloc(
        loginUsecase: sl(),
        registerUsecase: sl(),
        logoutUsecase: sl(),
      ));

  // Set up token interceptor
  final apiService = sl<ApiService>();
  final authApiService = sl<AuthApiService>();
  final secureStorage = sl<SecureStorageUtil>();

  final interceptor = TokenRefreshInterceptor(
    dio: apiService.dio,
    authApiService: authApiService,
    secureStorage: secureStorage,
  );

  apiService.addTokenRefreshInterceptor(interceptor);

  AppLogger.i('Core services initialized successfully');
}
