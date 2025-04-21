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

/// Event to create a new knowledge base
class CreateKnowledgeEvent extends KnowledgeEvent {
  final String knowledgeName;
  final String? description;
  final String? xJarvisGuid;

  const CreateKnowledgeEvent({
    required this.knowledgeName,
    this.description,
    this.xJarvisGuid,
  });

  @override
  List<Object?> get props => [knowledgeName, description, xJarvisGuid];
}

/// Event to delete a knowledge base
class DeleteKnowledgeEvent extends KnowledgeEvent {
  final String id;
  final String? xJarvisGuid;

  const DeleteKnowledgeEvent({
    required this.id,
    this.xJarvisGuid,
  });

  @override
  List<Object?> get props => [id, xJarvisGuid];
}

/// Event khi người dùng cập nhật một knowledge base
class UpdateKnowledgeEvent extends KnowledgeEvent {
  final String id;
  final String knowledgeName;
  final String description;
  final String? xJarvisGuid;

  const UpdateKnowledgeEvent({
    required this.id,
    required this.knowledgeName,
    required this.description,
    this.xJarvisGuid,
  });

  @override
  List<Object?> get props => [id, knowledgeName, description, xJarvisGuid];
}
