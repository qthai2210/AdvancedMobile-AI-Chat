import 'package:aichatbot/core/di/core_injection.dart' show sl;
import 'package:aichatbot/data/datasources/remote/user_profile_api_service.dart';
import 'package:aichatbot/data/repositories/user_profile_repository_impl.dart';
import 'package:aichatbot/domain/repositories/user_profile_repository.dart';
import 'package:aichatbot/domain/usecases/auth/get_user_profile_usecase.dart';
import 'package:aichatbot/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:aichatbot/utils/logger.dart';

/// Register dependencies for user profile functionality
void registerUserProfileDependencies() {
  AppLogger.i('Registering User Profile dependencies');

  // API Service
  if (!sl.isRegistered<UserProfileApiService>()) {
    sl.registerLazySingleton(() => UserProfileApiService());
  }

  // Repository
  if (!sl.isRegistered<UserProfileRepository>()) {
    sl.registerLazySingleton<UserProfileRepository>(
      () => UserProfileRepositoryImpl(userProfileApiService: sl()),
    );
  }

  // Use case
  if (!sl.isRegistered<GetUserProfileUseCase>()) {
    sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  }

  // Bloc
  if (!sl.isRegistered<UserProfileBloc>()) {
    sl.registerFactory(() => UserProfileBloc(getUserProfileUseCase: sl()));
  }
}
