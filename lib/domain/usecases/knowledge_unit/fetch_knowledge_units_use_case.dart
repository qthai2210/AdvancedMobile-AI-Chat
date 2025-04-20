import 'package:aichatbot/data/models/knowledge/knowledge_unit_model.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_units_response.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

class FetchKnowledgeUnitsUseCase {
  final KnowledgeRepository repository;

  FetchKnowledgeUnitsUseCase(this.repository);

  Future<KnowledgeUnitsResponse> execute({
    required String knowledgeId,
    required String accessToken,
  }) async {
    final KnowledgeUnitsResponse response = await repository.getKnowledgeUnits(
      knowledgeId: knowledgeId,
      accessToken: accessToken,
    );

    return response; // Return the entire response including metadata
  }
}
