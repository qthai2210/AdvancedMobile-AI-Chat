import 'package:bloc/bloc.dart';
import 'package:aichatbot/domain/usecases/generate_ai_email_usecase.dart';
import 'package:aichatbot/presentation/bloc/ai_email/ai_email_event.dart';
import 'package:aichatbot/presentation/bloc/ai_email/ai_email_state.dart';
import 'package:aichatbot/utils/logger.dart';

/// BLoC for managing AI Email generation state
class AiEmailBloc extends Bloc<AiEmailEvent, AiEmailState> {
  final GenerateAiEmailUseCase _generateAiEmailUseCase;

  AiEmailBloc(this._generateAiEmailUseCase) : super(AiEmailInitial()) {
    on<GenerateAiEmailEvent>(_onGenerateAiEmail);
    on<ClearAiEmailEvent>(_onClearAiEmail);
  }

  Future<void> _onGenerateAiEmail(
    GenerateAiEmailEvent event,
    Emitter<AiEmailState> emit,
  ) async {
    emit(AiEmailLoading());

    try {
      final params = GenerateAiEmailParams(
        mainIdea: event.mainIdea,
        action: event.action,
        email: event.email,
        subject: event.subject,
        sender: event.sender,
        receiver: event.receiver,
        style: event.style,
        language: event.language,
        guid: event.guid,
      );

      final result = await _generateAiEmailUseCase.execute(params);
      emit(AiEmailSuccess(
        email: result.email,
        remainingUsage: result.remainingUsage,
        improvedActions: result.improvedActions,
      ));
    } catch (e) {
      AppLogger.e('Error in bloc generating AI email: $e');
      emit(AiEmailFailure(e.toString()));
    }
  }

  void _onClearAiEmail(
    ClearAiEmailEvent event,
    Emitter<AiEmailState> emit,
  ) {
    emit(AiEmailInitial());
  }
}
