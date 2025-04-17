import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

/// Use case for deleting a knowledge base
class DeleteKnowledgeUseCase {
  final KnowledgeRepository repository;

  /// Creates a new instance of [DeleteKnowledgeUseCase]
  DeleteKnowledgeUseCase(this.repository);

  /// Execute the use case to delete a knowledge base
  ///
  /// [id] - ID of the knowledge base to delete
  /// [xJarvisGuid] - Optional GUID for tracking
  /// Returns true if deletion was successful
  Future<bool> call(String id, {String? xJarvisGuid}) async {
    return await repository.deleteKnowledge(id, xJarvisGuid: xJarvisGuid);
  }
}
