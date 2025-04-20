import 'package:aichatbot/data/models/knowledge/knowledge_unit_model.dart';
import 'package:equatable/equatable.dart';

abstract class KnowledgeUnitState extends Equatable {
  @override
  List<Object?> get props => [];
}

class KnowledgeUnitInitial extends KnowledgeUnitState {}

class KnowledgeUnitLoading extends KnowledgeUnitState {}

class KnowledgeUnitLoaded extends KnowledgeUnitState {
  final List<KnowledgeUnitModel> units;
  final Map<String, dynamic> meta;

  // Constructor with null safety for meta
  KnowledgeUnitLoaded({
    required this.units,
    Map<String, dynamic>? meta,
  }) : meta = meta ?? const {'total': 0, 'hasNext': false};

  @override
  List<Object?> get props => [units, meta];
}

class KnowledgeUnitError extends KnowledgeUnitState {
  final String message;

  KnowledgeUnitError({required this.message});

  @override
  List<Object?> get props => [message];
}
