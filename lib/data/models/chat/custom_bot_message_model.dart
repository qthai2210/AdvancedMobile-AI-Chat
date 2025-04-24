import 'package:equatable/equatable.dart';

/// Model class for a custom bot message request
class CustomBotMessageRequest extends Equatable {
  final String content;
  final List<String> files;
  final CustomBotMetadata metadata;
  final CustomBotAssistant assistant;

  const CustomBotMessageRequest({
    required this.content,
    required this.files,
    required this.metadata,
    required this.assistant,
  });

  @override
  List<Object?> get props => [content, files, metadata, assistant];

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'files': files,
      'metadata': metadata.toJson(),
      'assistant': assistant.toJson(),
    };
  }
}

/// Model class for custom bot message metadata
class CustomBotMetadata extends Equatable {
  final CustomBotConversation conversation;

  const CustomBotMetadata({
    required this.conversation,
  });

  @override
  List<Object?> get props => [conversation];

  Map<String, dynamic> toJson() {
    return {
      'conversation': conversation.toJson(),
    };
  }
}

/// Model class for conversation information in custom bot messages
class CustomBotConversation extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<CustomBotMessage> messages;

  const CustomBotConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  @override
  List<Object?> get props => [id, title, createdAt, messages];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}

/// Model class for individual messages in a custom bot conversation
class CustomBotMessage extends Equatable {
  final String role;
  final String content;
  final List<String>? files;
  final CustomBotAssistantReference? assistant;

  const CustomBotMessage({
    required this.role,
    required this.content,
    this.files,
    this.assistant,
  });

  @override
  List<Object?> get props => [role, content, files, assistant];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'role': role,
      'content': content,
    };

    if (files != null) {
      json['files'] = files;
    }

    if (assistant != null) {
      json['assistant'] = assistant!.toJson();
    }

    return json;
  }
}

/// Model class for assistant reference in messages
class CustomBotAssistantReference extends Equatable {
  final String model;
  final String name;
  final String id;

  const CustomBotAssistantReference({
    required this.model,
    required this.name,
    required this.id,
  });

  @override
  List<Object?> get props => [model, name, id];

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'name': name,
      'id': id,
    };
  }
}

/// Model class for assistant information in custom bot messages
class CustomBotAssistant extends Equatable {
  final String model;
  final String name;
  final String id;

  const CustomBotAssistant({
    required this.model,
    required this.name,
    required this.id,
  });

  @override
  List<Object?> get props => [model, name, id];

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'name': name,
      'id': id,
    };
  }
}

/// Model class for a custom bot message response
class CustomBotMessageResponse extends Equatable {
  final String message;
  final int remainingUsage;

  const CustomBotMessageResponse({
    required this.message,
    required this.remainingUsage,
  });

  factory CustomBotMessageResponse.fromJson(Map<String, dynamic> json) {
    return CustomBotMessageResponse(
      message: json['message'] as String,
      remainingUsage: json['remainingUsage'] as int,
    );
  }

  @override
  List<Object?> get props => [message, remainingUsage];

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'remainingUsage': remainingUsage,
    };
  }
}
