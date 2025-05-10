import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

class DeleteDatasourceUseCase {
  final KnowledgeRepository repository;
  DeleteDatasourceUseCase(this.repository);

  Future<void> call({
    required String knowledgeId,
    required String datasourceId,
    required String accessToken,
  }) {
    return repository.deleteDatasourceInKnowledge(
      knowledgeId: knowledgeId,
      datasourceId: datasourceId,
      accessToken: accessToken,
    );
  }
}
