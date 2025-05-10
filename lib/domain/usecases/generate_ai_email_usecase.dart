import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';
import 'package:aichatbot/domain/repositories/ai_email_repository.dart';
import 'package:equatable/equatable.dart';

/// Params for generating AI email
class GenerateAiEmailParams extends Equatable {
  final String mainIdea;
  final String action;
  final String email;
  final String subject;
  final String sender;
  final String receiver;
  final EmailStyleConfig style;
  final String language;
  final String? guid;

  const GenerateAiEmailParams({
    required this.mainIdea,
    required this.action,
    required this.email,
    required this.subject,
    required this.sender,
    required this.receiver,
    required this.style,
    required this.language,
    this.guid,
  });

  @override
  List<Object?> get props => [
        mainIdea,
        action,
        email,
        subject,
        sender,
        receiver,
        style,
        language,
        guid,
      ];
}

/// Use case for generating AI email
class GenerateAiEmailUseCase {
  final AiEmailRepository _repository;

  GenerateAiEmailUseCase(this._repository);

  /// Execute the use case
  Future<AiEmailResponse> execute(GenerateAiEmailParams params) async {
    return await _repository.generateEmail(
      mainIdea: params.mainIdea,
      action: params.action,
      email: params.email,
      subject: params.subject,
      sender: params.sender,
      receiver: params.receiver,
      style: params.style,
      language: params.language,
      guid: params.guid,
    );
  }
}
