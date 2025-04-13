import 'dart:convert';

import 'package:aichatbot/data/models/chat/conversation_request_params.dart';

class MessageRequestModel {
  final String content;
  final List<dynamic> files;
  final MessageMetadata metadata;
  final AssistantModel assistant;

  MessageRequestModel({
    required this.content,
    required this.files,
    required this.metadata,
    required this.assistant,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'files': files,
      'metadata': metadata.toJson(),
      'assistant': assistant.toJson(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class MessageMetadata {
  final Conversation conversation;

  MessageMetadata({
    required this.conversation,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation': conversation.toJson(),
    };
  }
}

class Conversation {
  final List<ChatMessage> messages;
  final String id;
  Conversation({
    required this.messages,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}

class ChatMessage {
  final String role;
  final String content;
  final List<dynamic> files;
  final AssistantModel? assistant;

  ChatMessage({
    required this.role,
    required this.content,
    required this.files,
    this.assistant,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'role': role,
      'content': content,
      'files': files,
    };

    if (assistant != null) {
      map['assistant'] = assistant!.toJson();
    }

    return map;
  }
}

class AssistantModel {
  final String model;
  final String name;
  final AssistantId id;

  AssistantModel({
    this.model = 'dify',
    required this.name,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'name': name,
      'id': id.toString(), // Convert enum to its string representation
    };
  }
}
