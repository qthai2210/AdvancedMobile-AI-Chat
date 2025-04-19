import 'package:aichatbot/data/models/chat/conversation_request_params.dart';
import 'package:equatable/equatable.dart';

/// Base class for all conversation-related events
abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to fetch conversation history
class FetchConversationHistory extends ConversationEvent {
  final String conversationId;
  final int? limit;
  final String? cursor;
  final AssistantId? assistantId;
  final String? xJarvisGuid;

  const FetchConversationHistory({
    required this.conversationId,
    this.limit,
    this.cursor,
    this.assistantId,
    this.xJarvisGuid,
  });

  @override
  List<Object?> get props =>
      [conversationId, limit, cursor, assistantId, xJarvisGuid];
}

/// Event triggered to fetch more conversation history items (pagination)
class FetchMoreConversationHistory extends ConversationEvent {
  final String conversationId;
  final int? limit;
  final String cursor;
  final AssistantId? assistantId;
  final String? xJarvisGuid;

  const FetchMoreConversationHistory({
    required this.conversationId,
    this.limit,
    required this.cursor,
    this.assistantId,
    this.xJarvisGuid,
  });

  @override
  List<Object?> get props =>
      [conversationId, limit, cursor, assistantId, xJarvisGuid];
}

/// Event triggered to fetch conversations
class FetchConversations extends ConversationEvent {
  final int? limit;
  final String? cursor;
  final AssistantId? assistantId;
  final String? xJarvisGuid;

  const FetchConversations({
    this.limit,
    this.cursor,
    this.assistantId,
    this.xJarvisGuid,
  });
  @override
  List<Object?> get props => [limit, cursor, assistantId, xJarvisGuid];
}

/// Event triggered to fetch more conversations (pagination)
class FetchMoreConversations extends ConversationEvent {
  final String accessToken;
  final int? limit;
  final String cursor;

  const FetchMoreConversations({
    required this.accessToken,
    this.limit,
    required this.cursor,
  });

  @override
  List<Object?> get props => [accessToken, limit, cursor];
}

/// Event triggered to reset the conversations state
class ResetConversations extends ConversationEvent {}

/// Event triggered to create a new conversation
class CreateConversation extends ConversationEvent {
  final String accessToken;
  final String title;
  final String initialMessage;

  const CreateConversation({
    required this.accessToken,
    required this.title,
    required this.initialMessage,
  });

  @override
  List<Object?> get props => [accessToken, title, initialMessage];
}

/// Event triggered to delete a conversation
class DeleteConversation extends ConversationEvent {
  final String accessToken;
  final String conversationId;

  const DeleteConversation({
    required this.accessToken,
    required this.conversationId,
  });

  @override
  List<Object?> get props => [accessToken, conversationId];
}

/// Event triggered to update a conversation
class UpdateConversation extends ConversationEvent {
  final String accessToken;
  final String conversationId;
  final String title;

  const UpdateConversation({
    required this.accessToken,
    required this.conversationId,
    required this.title,
  });

  @override
  List<Object?> get props => [accessToken, conversationId, title];
}

/// Event triggered to send a new message
class SendMessage extends ConversationEvent {
  final String accessToken;
  final String message;
  final List<String>? imageAttachments;
  final String? conversationId;
  final List<Map<String, dynamic>>? conversationHistory;
  final String? selectedAgent;

  const SendMessage({
    required this.accessToken,
    required this.message,
    this.imageAttachments,
    this.conversationId,
    this.conversationHistory,
    this.selectedAgent,
  });

  @override
  List<Object?> get props => [
        accessToken,
        message,
        imageAttachments,
        conversationId,
        conversationHistory,
        selectedAgent
      ];
}

/// Event triggered to continue iterating on the last response
class ContinueIteration extends ConversationEvent {
  final String accessToken;
  final String? conversationId;
  final String lastMessageId;
  final List<Map<String, dynamic>>? conversationHistory;

  const ContinueIteration({
    required this.accessToken,
    this.conversationId,
    required this.lastMessageId,
    this.conversationHistory,
  });

  @override
  List<Object?> get props =>
      [accessToken, conversationId, lastMessageId, conversationHistory];
}
