import 'package:aichatbot/data/datasources/remote/knowledge_api_service.dart';
import 'package:aichatbot/data/models/knowledge/get_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_list_response.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';
import 'package:aichatbot/utils/logger.dart';

class KnowledgeRepositoryImpl implements KnowledgeRepository {
  final KnowledgeApiService knowledgeApiService;

  KnowledgeRepositoryImpl({required this.knowledgeApiService});

  @override
  Future<KnowledgeListResponse> getKnowledges(GetKnowledgeParams params) async {
    try {
      final response = await knowledgeApiService.getKnowledges(params);
      return response;
    } catch (e) {
      AppLogger.e('Repository error fetching knowledges: $e');
      rethrow;
    }
  }
}
