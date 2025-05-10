import 'package:aichatbot/core/di/core_injection.dart';
import 'package:aichatbot/data/datasources/remote/email_api_service.dart';
import 'package:aichatbot/data/repositories/ai_email_repository_impl.dart';
import 'package:aichatbot/domain/repositories/ai_email_repository.dart';
import 'package:aichatbot/domain/usecases/generate_ai_email_usecase.dart';
import 'package:aichatbot/presentation/bloc/ai_email/ai_email_bloc.dart';

/// Registers all dependencies related to AI email generation
void registerAiEmailDependencies() {
  // API Service is already registered in email_reply_suggestion_injection.dart

  // Repository
  sl.registerLazySingleton<AiEmailRepository>(
    () => AiEmailRepositoryImpl(sl<EmailApiService>()),
  );

  // UseCase
  sl.registerLazySingleton(() => GenerateAiEmailUseCase(sl()));

  // BLoC
  sl.registerFactory(() => AiEmailBloc(sl()));
}
