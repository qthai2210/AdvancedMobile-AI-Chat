import 'package:aichatbot/data/models/assistant/assistant_list_response.dart';
import 'package:aichatbot/data/models/assistant/get_assistants_params.dart';
import 'package:aichatbot/domain/repositories/assistant_repository.dart';

/// Use case for retrieving a list of AI assistants
class GetAssistantsUseCase {
  final AssistantRepository _repository;

  /// Creates a new instance of [GetAssistantsUseCase]
  GetAssistantsUseCase(this._repository);

  /// Executes the use case to retrieve assistants
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
  Future<AssistantListResponse> call({
    String? query,
    SortOrder? order = SortOrder.DESC,
    String? orderField,
    int offset = 0,
    int limit = 10,
    bool? isFavorite,
    bool? isPublished,
    String? xJarvisGuid,
  }) async {
    return await _repository.getAssistants(
      query: query,
      order: order,
      orderField: orderField,
      offset: offset,
      limit: limit,
      isFavorite: isFavorite,
      isPublished: isPublished,
      xJarvisGuid: xJarvisGuid,
    );
  }
}
