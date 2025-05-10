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

/// Model for AI email style configuration
class EmailStyleConfig extends Equatable {
  final String length;
  final String formality;
  final String tone;

  const EmailStyleConfig({
    required this.length,
    required this.formality,
    required this.tone,
  });

  Map<String, dynamic> toJson() {
    return {
      'length': length,
      'formality': formality,
      'tone': tone,
    };
  }

  @override
  List<Object?> get props => [length, formality, tone];

  factory EmailStyleConfig.fromJson(Map<String, dynamic> json) {
    return EmailStyleConfig(
      length: json['length'] as String,
      formality: json['formality'] as String,
      tone: json['tone'] as String,
    );
  }
}

/// Model for AI email metadata
class AiEmailMetadata extends Equatable {
  final List<dynamic> context;
  final String subject;
  final String sender;
  final String receiver;
  final EmailStyleConfig style;
  final String language;

  const AiEmailMetadata({
    required this.context,
    required this.subject,
    required this.sender,
    required this.receiver,
    required this.style,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'context': context,
      'subject': subject,
      'sender': sender,
      'receiver': receiver,
      'style': style.toJson(),
      'language': language,
    };
  }

  @override
  List<Object?> get props =>
      [context, subject, sender, receiver, style, language];

  factory AiEmailMetadata.fromJson(Map<String, dynamic> json) {
    return AiEmailMetadata(
      context: json['context'] as List<dynamic>,
      subject: json['subject'] as String,
      sender: json['sender'] as String,
      receiver: json['receiver'] as String,
      style: EmailStyleConfig.fromJson(json['style'] as Map<String, dynamic>),
      language: json['language'] as String,
    );
  }
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

/// Request model for AI email generation
class AiEmailRequest {
  final String mainIdea;
  final String action;
  final String email;
  final AiEmailMetadata metadata;

  const AiEmailRequest({
    required this.mainIdea,
    required this.action,
    required this.email,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'mainIdea': mainIdea,
      'action': action,
      'email': email,
      'metadata': metadata.toJson(),
    };
  }
}

/// Response model for AI email generation
class AiEmailResponse {
  final String email;
  final int remainingUsage;
  final List<String> improvedActions;

  const AiEmailResponse({
    required this.email,
    required this.remainingUsage,
    required this.improvedActions,
  });

  factory AiEmailResponse.fromJson(Map<String, dynamic> json) {
    return AiEmailResponse(
      email: json['email'] as String,
      remainingUsage: json['remainingUsage'] as int,
      improvedActions: List<String>.from(json['improvedActions']),
    );
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
