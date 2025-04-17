import 'package:aichatbot/data/models/knowledge/get_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_list_response.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

/// Use case for retrieving a list of knowledge bases
class GetKnowledgesUseCase {
  final KnowledgeRepository _repository;

  /// Creates a new instance of [GetKnowledgesUseCase]
  GetKnowledgesUseCase(this._repository);

  /// Executes the use case to retrieve knowledge bases
  ///
  /// Parameters match the API specification from APIdog:
  /// - [query] Optional search query string
  /// - [order] Sort order (ASC or DESC)
  /// - [orderField] Field to order by (e.g., "createdAt")
  /// - [offset] Starting position for pagination
  /// - [limit] Maximum number of results to return (1-50)
  Future<KnowledgeListResponse> execute({
    String? query,
    String? order,
    String? orderField,
    int offset = 0,
    int limit = 10,
  }) async {
    final params = GetKnowledgeParams(
      query: query,
      order: order,
      orderField: orderField,
      offset: offset,
      limit: limit,
    );

    return await _repository.getKnowledges(params);
  }
}
