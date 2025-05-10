import 'package:aichatbot/core/di/core_injection.dart';
import 'package:aichatbot/data/datasources/remote/email_api_service.dart';
import 'package:aichatbot/data/repositories/email_reply_suggestion_repository_impl.dart';
import 'package:aichatbot/domain/repositories/email_reply_suggestion_repository.dart';
import 'package:aichatbot/domain/usecases/get_email_reply_suggestions_usecase.dart';
import 'package:aichatbot/presentation/bloc/email_reply_suggestion/email_reply_suggestion_bloc.dart';

/// Registers all dependencies related to email reply suggestions
void registerEmailReplySuggestionDependencies() {
  // API Service
  sl.registerLazySingleton(() => EmailApiService());

  // Repository
  sl.registerLazySingleton<EmailReplySuggestionRepository>(
    () => EmailReplySuggestionRepositoryImpl(sl<EmailApiService>()),
  );

  // UseCase
  sl.registerLazySingleton(() => GetEmailReplySuggestionsUseCase(sl()));

  // BLoC
  sl.registerFactory(() => EmailReplySuggestionBloc(sl()));
}
