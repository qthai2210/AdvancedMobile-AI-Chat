import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:equatable/equatable.dart';

/// States for the Bot BLoC
abstract class BotState extends Equatable {
  const BotState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no assistants have been loaded
class BotInitial extends BotState {}

/// State when assistants are being loaded for the first time
class BotsLoading extends BotState {}

/// State when more assistants are being loaded (pagination)
class BotsLoadingMore extends BotState {
  final List<AssistantModel> bots;
  final bool hasMore;

  const BotsLoadingMore({
    required this.bots,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [bots, hasMore];
}

/// State when assistants have been successfully loaded
class BotsLoaded extends BotState {
  final List<AssistantModel> bots;
  final bool hasMore;
  final int offset;
  final int total;

  const BotsLoaded({
    required this.bots,
    required this.hasMore,
    required this.offset,
    required this.total,
  });

  @override
  List<Object?> get props => [bots, hasMore, offset, total];
}

/// State when there's an error loading assistants
class BotsError extends BotState {
  final String message;

  const BotsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when an assistant is being created
class AssistantCreating extends BotState {}

/// State when an assistant has been successfully created
class AssistantCreated extends BotState {
  final AssistantModel assistant;

  const AssistantCreated({required this.assistant});

  @override
  List<Object?> get props => [assistant];
}

/// State when there was an error creating an assistant
class AssistantCreationFailed extends BotState {
  final String message;

  const AssistantCreationFailed({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when an assistant is being updated
class AssistantUpdating extends BotState {}

/// State when an assistant has been successfully updated
class AssistantUpdated extends BotState {
  final AssistantModel assistant;

  const AssistantUpdated({required this.assistant});

  @override
  List<Object?> get props => [assistant];
}

/// State when there was an error updating an assistant
class AssistantUpdateFailed extends BotState {
  final String message;

  const AssistantUpdateFailed({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when an assistant is being deleted
class AssistantDeleting extends BotState {}

/// State when an assistant has been successfully deleted
class AssistantDeleted extends BotState {
  final String assistantId;

  const AssistantDeleted({required this.assistantId});

  @override
  List<Object?> get props => [assistantId];
}

/// State when there was an error deleting an assistant
class AssistantDeleteFailed extends BotState {
  final String message;

  const AssistantDeleteFailed({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when linking a knowledge base to an assistant
class AssistantLinkingKnowledge extends BotState {}

/// State when a knowledge base has been successfully linked to an assistant
class AssistantKnowledgeLinked extends BotState {
  final String assistantId;
  final String knowledgeId;

  const AssistantKnowledgeLinked({
    required this.assistantId,
    required this.knowledgeId,
  });

  @override
  List<Object?> get props => [assistantId, knowledgeId];
}

/// State when there was an error linking a knowledge base to an assistant
class AssistantKnowledgeLinkFailed extends BotState {
  final String message;

  const AssistantKnowledgeLinkFailed({required this.message});

  @override
  List<Object?> get props => [message];
}
