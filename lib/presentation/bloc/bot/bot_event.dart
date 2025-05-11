import 'package:equatable/equatable.dart';

/// Events for the Bot BLoC
abstract class BotEvent extends Equatable {
  const BotEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch all assistants/bots with optional parameters
class FetchBotsEvent extends BotEvent {
  final String? searchQuery;
  final int limit;
  final int offset;
  final bool? isFavorite;

  const FetchBotsEvent({
    this.searchQuery,
    this.limit = 20,
    this.offset = 0,
    this.isFavorite,
  });

  @override
  List<Object?> get props => [searchQuery, limit, offset, isFavorite];
}

/// Event to fetch more assistants/bots (pagination)
class FetchMoreBotsEvent extends BotEvent {
  final int limit;
  final int offset;
  final String? searchQuery;
  final bool? isFavorite;

  const FetchMoreBotsEvent({
    required this.offset,
    this.limit = 20,
    this.searchQuery,
    this.isFavorite,
  });

  @override
  List<Object?> get props => [limit, offset, searchQuery, isFavorite];
}

/// Event to refresh the list of assistants/bots
class RefreshBotsEvent extends BotEvent {
  final String? searchQuery;
  final bool? isFavorite;

  const RefreshBotsEvent({
    this.searchQuery,
    this.isFavorite,
  });

  @override
  List<Object?> get props => [searchQuery, isFavorite];
}

/// Event to create a new assistant
class CreateAssistantEvent extends BotEvent {
  final String assistantName;
  final String? instructions;
  final String? description;
  final String? guidId;

  const CreateAssistantEvent({
    required this.assistantName,
    this.instructions,
    this.description,
    this.guidId,
  });

  @override
  List<Object?> get props => [assistantName, instructions, description, guidId];
}

/// Event to update an existing assistant
class UpdateAssistantEvent extends BotEvent {
  final String assistantId;
  final String assistantName;
  final String? instructions;
  final String? description;
  final String? xJarvisGuid;

  const UpdateAssistantEvent({
    required this.assistantId,
    required this.assistantName,
    this.instructions,
    this.description,
    this.xJarvisGuid,
  });

  @override
  List<Object?> get props =>
      [assistantId, assistantName, instructions, description, xJarvisGuid];
}

/// Event to delete an existing assistant
class DeleteAssistantEvent extends BotEvent {
  final String assistantId;
  final String? xJarvisGuid;

  const DeleteAssistantEvent({
    required this.assistantId,
    this.xJarvisGuid,
  });

  @override
  List<Object?> get props => [assistantId, xJarvisGuid];
}

/// Event to link a knowledge base to an assistant
class LinkKnowledgeToAssistantEvent extends BotEvent {
  final String assistantId;
  final String knowledgeId;
  final String? accessToken;
  final String? xJarvisGuid;

  const LinkKnowledgeToAssistantEvent({
    required this.assistantId,
    required this.knowledgeId,
    this.accessToken,
    this.xJarvisGuid,
  });

  @override
  List<Object?> get props =>
      [assistantId, knowledgeId, accessToken, xJarvisGuid];
}

/// Event to remove a knowledge base from an assistant
class RemoveKnowledgeFromAssistantEvent extends BotEvent {
  final String assistantId;
  final String knowledgeId;
  final String? accessToken;
  final String? xJarvisGuid;

  const RemoveKnowledgeFromAssistantEvent({
    required this.assistantId,
    required this.knowledgeId,
    this.accessToken,
    this.xJarvisGuid,
  });

  @override
  List<Object?> get props =>
      [assistantId, knowledgeId, accessToken, xJarvisGuid];
}
