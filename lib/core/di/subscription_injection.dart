import 'package:aichatbot/core/di/core_injection.dart';
import 'package:aichatbot/data/datasources/remote/subscription_api_service.dart';
import 'package:aichatbot/data/repositories/subscription_repository_impl.dart';
import 'package:aichatbot/domain/repositories/subscription_repository.dart';
import 'package:aichatbot/domain/usecases/get_user_subscription_usecase.dart';
import 'package:aichatbot/domain/usecases/update_user_subscription_usecase.dart';
import 'package:aichatbot/presentation/bloc/subscription/subscription_bloc.dart';

/// Registers all dependencies related to subscription management
void registerSubscriptionDependencies() {
  // API Service
  sl.registerLazySingleton(() => SubscriptionApiService());

  // Repository
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(sl<SubscriptionApiService>()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetUserSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserSubscriptionUseCase(sl()));

  // BLoC
  sl.registerFactory(() => SubscriptionBloc(sl(), sl()));
}
