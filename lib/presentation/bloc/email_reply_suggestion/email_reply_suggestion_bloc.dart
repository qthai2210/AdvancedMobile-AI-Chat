import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';
import 'package:aichatbot/domain/usecases/get_email_reply_suggestions_usecase.dart';
import 'package:aichatbot/utils/logger.dart';

// Events
abstract class EmailReplySuggestionEvent extends Equatable {
  const EmailReplySuggestionEvent();

  @override
  List<Object?> get props => [];
}

class GetEmailReplySuggestionsEvent extends EmailReplySuggestionEvent {
  final String email;
  final String subject;
  final String sender;
  final String receiver;
  final String language;
  final String? guid;
  final String? authToken;
  final String action;
  final String model;

  const GetEmailReplySuggestionsEvent({
    required this.email,
    required this.subject,
    required this.sender,
    required this.receiver,
    required this.language,
    this.guid,
    this.authToken,
    this.action = "Suggest 3 ideas for this email",
    this.model = "dify",
  });

  @override
  List<Object?> get props => [
        email,
        subject,
        sender,
        receiver,
        language,
        guid,
        authToken,
        action,
        model,
      ];
}

// States
abstract class EmailReplySuggestionState extends Equatable {
  const EmailReplySuggestionState();

  @override
  List<Object?> get props => [];
}

class EmailReplySuggestionInitial extends EmailReplySuggestionState {}

class EmailReplySuggestionLoading extends EmailReplySuggestionState {}

class EmailReplySuggestionSuccess extends EmailReplySuggestionState {
  final List<String> ideas;

  const EmailReplySuggestionSuccess(this.ideas);

  @override
  List<Object?> get props => [ideas];
}

class EmailReplySuggestionFailure extends EmailReplySuggestionState {
  final String error;

  const EmailReplySuggestionFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// BLoC
class EmailReplySuggestionBloc
    extends Bloc<EmailReplySuggestionEvent, EmailReplySuggestionState> {
  final GetEmailReplySuggestionsUseCase _getEmailReplySuggestionsUseCase;

  EmailReplySuggestionBloc(this._getEmailReplySuggestionsUseCase)
      : super(EmailReplySuggestionInitial()) {
    on<GetEmailReplySuggestionsEvent>(_onGetEmailReplySuggestions);
  }

  Future<void> _onGetEmailReplySuggestions(
    GetEmailReplySuggestionsEvent event,
    Emitter<EmailReplySuggestionState> emit,
  ) async {
    emit(EmailReplySuggestionLoading());

    try {
      final params = EmailReplySuggestionParams(
        email: event.email,
        subject: event.subject,
        sender: event.sender,
        receiver: event.receiver,
        language: event.language,
        guid: event.guid,
        authToken: event.authToken,
        action: event.action,
        model: event.model,
      );

      final result = await _getEmailReplySuggestionsUseCase.execute(params);
      emit(EmailReplySuggestionSuccess(result.ideas));
    } catch (e) {
      AppLogger.e('Error in bloc getting email reply suggestions: $e');
      emit(EmailReplySuggestionFailure(e.toString()));
    }
  }
}
