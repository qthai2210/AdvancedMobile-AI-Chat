import 'package:aichatbot/data/models/chat/message_request_model.dart';
import 'package:equatable/equatable.dart';

/// Base state class for the conversation bloc
abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any events are processed
class ConversationInitial extends ConversationState {}

/// State when conversations are being loaded
class ConversationLoading extends ConversationState {}

/// State when more conversations are being loaded (pagination)
class ConversationLoadingMore extends ConversationState {
  final List<Conversation> conversations;
  final bool hasMore;

  const ConversationLoadingMore({
    required this.conversations,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [conversations, hasMore];
}

/// State when conversations have been successfully loaded
class ConversationLoaded extends ConversationState {
  final List<Conversation> conversations;
  final bool hasMore;
  final String? nextCursor;

  const ConversationLoaded({
    required this.conversations,
    required this.hasMore,
    this.nextCursor,
  });

  @override
  List<Object?> get props => [conversations, hasMore, nextCursor];
}

/// State when an error occurs during conversation operations
class ConversationError extends ConversationState {
  final String message;

  const ConversationError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when a conversation is being created
class ConversationCreating extends ConversationState {}

/// State when a conversation has been successfully created
class ConversationCreated extends ConversationState {
  final Conversation conversation;

  const ConversationCreated({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}

/// State when a conversation is being updated
class ConversationUpdating extends ConversationState {}

/// State when a conversation has been successfully updated
class ConversationUpdated extends ConversationState {
  final Conversation conversation;

  const ConversationUpdated({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}

/// State when a conversation is being deleted
class ConversationDeleting extends ConversationState {}

/// State when a conversation has been successfully deleted
class ConversationDeleted extends ConversationState {
  final String conversationId;

  const ConversationDeleted({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}

/// State when a message is being sent
class MessageSending extends ConversationState {}

/// State when an AI is generating a response
class MessageGenerating extends ConversationState {
  final String userMessage;
  final List<String>? imageAttachments;

  const MessageGenerating({
    required this.userMessage,
    this.imageAttachments,
  });

  @override
  List<Object?> get props => [userMessage, imageAttachments];
}

/// State when a message has been successfully sent and received a response
class MessageSent extends ConversationState {
  final String userMessage;
  final String responseMessage;
  final String messageId;
  final List<String>? imageAttachments;
  final String? conversationId;

  const MessageSent({
    required this.userMessage,
    required this.responseMessage,
    required this.messageId,
    this.imageAttachments,
    this.conversationId,
  });

  @override
  List<Object?> get props => [
        userMessage,
        responseMessage,
        messageId,
        imageAttachments,
        conversationId
      ];
}

/// State when continuing to iterate on a previous response
class ContinuingIteration extends ConversationState {
  final String lastMessageId;

  const ContinuingIteration({required this.lastMessageId});

  @override
  List<Object?> get props => [lastMessageId];
}

/// State when iteration continuation is complete
class IterationContinued extends ConversationState {
  final String additionalResponse;
  final String messageId;

  const IterationContinued({
    required this.additionalResponse,
    required this.messageId,
  });

  @override
  List<Object?> get props => [additionalResponse, messageId];
}

/// State when there's an error in sending a message or continuing iteration
class MessageError extends ConversationState {
  final String message;

  const MessageError({required this.message});

  @override
  List<Object?> get props => [message];
}
