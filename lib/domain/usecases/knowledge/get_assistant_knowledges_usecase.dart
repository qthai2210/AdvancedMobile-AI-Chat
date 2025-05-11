import 'package:aichatbot/data/models/knowledge/knowledge_list_response.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

/// Use case for fetching knowledge bases attached to a specific assistant
class GetAssistantKnowledgesUseCase {
  final KnowledgeRepository repository;

  GetAssistantKnowledgesUseCase(this.repository);

  /// Execute the use case to get knowledge bases attached to an assistant
  ///
  /// [assistantId] is required to identify the assistant
  /// [q] optional search query
  /// [order] optional sort order (ASC/DESC)
  /// [orderField] optional field to sort by
  /// [offset] optional pagination offset
  /// [limit] optional pagination limit
  /// [xJarvisGuid] optional tracking GUID
  /// [accessToken] optional access token for authorization
  Future<KnowledgeListResponse> execute({
    required String assistantId,
    String? q,
    String? order = "DESC",
    String? orderField = "createdAt",
    int offset = 0,
    int limit = 10,
    String? xJarvisGuid,
    String? accessToken,
  }) async {
    return await repository.getAssistantKnowledges(
      assistantId: assistantId,
      q: q,
      order: order,
      orderField: orderField,
      offset: offset,
      limit: limit,
      xJarvisGuid: xJarvisGuid,
      accessToken: accessToken,
    );
  }
}
