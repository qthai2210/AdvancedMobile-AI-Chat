import 'package:aichatbot/data/models/knowledge/knowledge_list_response.dart';
import 'package:aichatbot/data/models/knowledge/get_knowledge_params.dart';

/// Repository interface for Knowledge-related operations
abstract class KnowledgeRepository {
  /// Fetches knowledge items based on the provided parameters
  ///
  /// [params] - The parameters to filter and paginate the results
  /// Returns a [KnowledgeListResponse] containing the list of knowledges and metadata
  Future<KnowledgeListResponse> getKnowledges(GetKnowledgeParams params);
}
