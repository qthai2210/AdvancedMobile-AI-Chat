import 'package:equatable/equatable.dart';

/// Model representing an email content
class EmailContent extends Equatable {
  final String subject;
  final String sender;
  final String receiver;
  final String content;

  const EmailContent({
    required this.subject,
    required this.sender,
    required this.receiver,
    required this.content,
  });

  @override
  List<Object?> get props => [subject, sender, receiver, content];
}

/// Model representing metadata for AI email reply ideas
class AiEmailReplyIdeasMetadata extends Equatable {
  final List<dynamic> context;
  final String subject;
  final String sender;
  final String receiver;
  final String language;

  const AiEmailReplyIdeasMetadata({
    required this.context,
    required this.subject,
    required this.sender,
    required this.receiver,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'context': context,
      'subject': subject,
      'sender': sender,
      'receiver': receiver,
      'language': language,
    };
  }

  @override
  List<Object?> get props => [context, subject, sender, receiver, language];
}

/// Model for assistant options
class AssistantDto {
  final String? id;
  final String model;

  const AssistantDto({
    this.id,
    required this.model,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'model': model,
    };
  }
}

/// Request model for email reply ideas suggestion
class EmailReplySuggestionRequest {
  final AssistantDto? assistant;
  final String model;
  final String email;
  final String action;
  final AiEmailReplyIdeasMetadata metadata;

  const EmailReplySuggestionRequest({
    this.assistant,
    this.model = 'dify',
    required this.email,
    required this.action,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      if (assistant != null) 'assistant': assistant!.toJson(),
      'model': model,
      'email': email,
      'action': action,
      'metadata': metadata.toJson(),
    };
  }
}

/// Response model for email reply ideas
class EmailReplySuggestionResponse {
  final List<String> ideas;

  const EmailReplySuggestionResponse({
    required this.ideas,
  });

  factory EmailReplySuggestionResponse.fromJson(Map<String, dynamic> json) {
    return EmailReplySuggestionResponse(
      ideas: List<String>.from(json['ideas']),
    );
  }
}
