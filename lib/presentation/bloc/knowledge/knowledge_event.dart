import 'package:equatable/equatable.dart';

/// Events for the Knowledge BLoC
abstract class KnowledgeEvent extends Equatable {
  const KnowledgeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch all knowledge bases with optional parameters
class FetchKnowledgesEvent extends KnowledgeEvent {
  final String? searchQuery;
  final String? order;
  final String? orderField;
  final int offset;
  final int limit;

  const FetchKnowledgesEvent({
    this.searchQuery,
    this.order,
    this.orderField,
    this.offset = 0,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [searchQuery, order, orderField, offset, limit];
}

/// Event to fetch more knowledge bases (for pagination)
class FetchMoreKnowledgesEvent extends KnowledgeEvent {
  final String? searchQuery;
  final String? order;
  final String? orderField;
  final int offset;
  final int limit;

  const FetchMoreKnowledgesEvent({
    this.searchQuery,
    this.order,
    this.orderField,
    required this.offset,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [searchQuery, order, orderField, offset, limit];
}

/// Event to refresh the knowledge bases list
class RefreshKnowledgesEvent extends KnowledgeEvent {
  final String? searchQuery;
  final String? order;
  final String? orderField;
  final int limit;

  const RefreshKnowledgesEvent({
    this.searchQuery,
    this.order,
    this.orderField,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [searchQuery, order, orderField, limit];
}
