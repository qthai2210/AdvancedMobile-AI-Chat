import 'package:equatable/equatable.dart';
import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';

/// Base class for all AI Email events
abstract class AiEmailEvent extends Equatable {
  const AiEmailEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request AI email generation
class GenerateAiEmailEvent extends AiEmailEvent {
  final String mainIdea;
  final String action;
  final String email;
  final String subject;
  final String sender;
  final String receiver;
  final EmailStyleConfig style;
  final String language;
  final String? guid;

  const GenerateAiEmailEvent({
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

/// Event to clear the current state
class ClearAiEmailEvent extends AiEmailEvent {}
