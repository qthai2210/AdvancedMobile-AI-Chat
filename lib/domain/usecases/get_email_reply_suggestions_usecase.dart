import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';
import 'package:aichatbot/domain/repositories/email_reply_suggestion_repository.dart';
import 'package:equatable/equatable.dart';

/// Params for getting email reply suggestions
class EmailReplySuggestionParams extends Equatable {
  final String email;
  final String subject;
  final String sender;
  final String receiver;
  final String language;
  final String? guid;
  final String? authToken;
  final String action;
  final String model;

  const EmailReplySuggestionParams({
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

/// Use case for getting email reply suggestions
class GetEmailReplySuggestionsUseCase {
  final EmailReplySuggestionRepository _repository;

  GetEmailReplySuggestionsUseCase(this._repository);

  /// Execute the use case
  Future<EmailReplySuggestionResponse> execute(
      EmailReplySuggestionParams params) async {
    return await _repository.getSuggestions(
      email: params.email,
      subject: params.subject,
      sender: params.sender,
      receiver: params.receiver,
      language: params.language,
      guid: params.guid,
      authToken: params.authToken,
      action: params.action,
      model: params.model,
    );
  }
}
