import 'package:aichatbot/data/datasources/remote/knowledge_api_service.dart';
import 'package:aichatbot/data/models/knowledge/get_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_list_response.dart';
import 'package:aichatbot/data/models/knowledge/create_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
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

  @override
  Future<KnowledgeModel> createKnowledge(CreateKnowledgeParams params) async {
    try {
      AppLogger.d('Creating knowledge with name: ${params.knowledgeName}');
      final result = await knowledgeApiService.createKnowledge(params);
      AppLogger.i('Knowledge created successfully: ${result.knowledgeName}');
      return result;
    } catch (e) {
      AppLogger.e('Repository error creating knowledge: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteKnowledge(String id, {String? xJarvisGuid}) async {
    try {
      AppLogger.d('Repository deleting knowledge with ID: $id');
      final result = await knowledgeApiService.deleteKnowledge(id,
          xJarvisGuid: xJarvisGuid);
      AppLogger.i('Knowledge deleted successfully: $result');
      return result;
    } catch (e) {
      AppLogger.e('Repository error deleting knowledge: $e');
      rethrow;
    }
  }
}
