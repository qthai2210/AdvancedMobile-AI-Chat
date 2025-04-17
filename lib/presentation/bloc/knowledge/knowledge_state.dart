import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
import 'package:equatable/equatable.dart';

/// States for the Knowledge BLoC
abstract class KnowledgeState extends Equatable {
  const KnowledgeState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no knowledge bases have been loaded yet
class KnowledgeInitial extends KnowledgeState {}

/// State when knowledge bases are being loaded
class KnowledgeLoading extends KnowledgeState {}

/// State when more knowledge bases are being loaded (pagination)
class KnowledgeLoadingMore extends KnowledgeState {
  final List<KnowledgeModel> knowledges;
  final bool hasReachedMax;
  final int currentOffset;
  final int total;

  const KnowledgeLoadingMore({
    required this.knowledges,
    required this.hasReachedMax,
    required this.currentOffset,
    required this.total,
  });

  @override
  List<Object?> get props => [knowledges, hasReachedMax, currentOffset, total];
}

/// State when knowledge bases are loaded successfully
class KnowledgeLoaded extends KnowledgeState {
  final List<KnowledgeModel> knowledges;
  final bool hasReachedMax;
  final int currentOffset;
  final int total;

  const KnowledgeLoaded({
    required this.knowledges,
    required this.hasReachedMax,
    required this.currentOffset,
    required this.total,
  });

  @override
  List<Object?> get props => [knowledges, hasReachedMax, currentOffset, total];
}

/// State when there's an error loading knowledge bases
class KnowledgeError extends KnowledgeState {
  final String message;

  const KnowledgeError(this.message);

  @override
  List<Object> get props => [message];
}
