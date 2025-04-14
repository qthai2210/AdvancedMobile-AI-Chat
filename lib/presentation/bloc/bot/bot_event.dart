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
