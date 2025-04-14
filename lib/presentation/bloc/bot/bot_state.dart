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
