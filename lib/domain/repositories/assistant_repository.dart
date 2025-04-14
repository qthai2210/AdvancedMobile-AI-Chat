import 'package:aichatbot/data/models/assistant/assistant_list_response.dart';
import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/data/models/assistant/get_assistants_params.dart';

/// Repository interface for assistant-related operations
abstract class AssistantRepository {
  /// Retrieves a list of AI assistants with optional filtering and pagination
  ///
  /// Parameters match the API specification from APIdog:
  /// - [query] Optional search query string
  /// - [order] Sort order (ASC or DESC)
  /// - [orderField] Field to order by (e.g., "createdAt")
  /// - [offset] Starting position for pagination
  /// - [limit] Maximum number of results to return (1-50)
  /// - [isFavorite] Filter by favorite status
  /// - [isPublished] Filter by published status
  /// - [xJarvisGuid] Optional GUID for tracking
  Future<AssistantListResponse> getAssistants({
    String? query,
    SortOrder? order,
    String? orderField,
    int? offset,
    int? limit,
    bool? isFavorite,
    bool? isPublished,
    String? xJarvisGuid,
  });

  /// Retrieves a specific AI assistant by ID
  Future<AssistantModel> getAssistantById(String assistantId,
      {String? xJarvisGuid});
}
