import 'package:aichatbot/data/models/knowledge/create_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

/// Use case for creating a new knowledge base
class CreateKnowledgeUseCase {
  final KnowledgeRepository repository;

  /// Creates a new instance of [CreateKnowledgeUseCase]
  CreateKnowledgeUseCase(this.repository);

  /// Execute the use case to create a knowledge base
  ///
  /// [params] The parameters for creating a knowledge base
  /// Returns the created [KnowledgeModel]
  Future<KnowledgeModel> call(CreateKnowledgeParams params) async {
    return await repository.createKnowledge(params);
  }
}
