import 'package:aichatbot/data/models/knowledge/create_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_list_response.dart';
import 'package:aichatbot/data/models/knowledge/get_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';

/// Repository interface for Knowledge-related operations
abstract class KnowledgeRepository {
  /// Fetches knowledge items based on the provided parameters
  ///
  /// [params] - The parameters to filter and paginate the results
  /// Returns a [KnowledgeListResponse] containing the list of knowledges and metadata
  Future<KnowledgeListResponse> getKnowledges(GetKnowledgeParams params);

  /// Creates a new knowledge base with the provided parameters
  ///
  /// [params] - The parameters containing the knowledge name and optional description
  /// Returns the created [KnowledgeModel] on success
  Future<KnowledgeModel> createKnowledge(CreateKnowledgeParams params);

  /// Deletes a knowledge base with the specified ID
  ///
  /// [id] - The ID of the knowledge base to delete
  /// [xJarvisGuid] - Optional GUID for tracking
  /// Returns true if deletion was successful
  Future<bool> deleteKnowledge(String id, {String? xJarvisGuid});
}
