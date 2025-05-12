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

  /// Creates a new AI assistant
  ///
  /// [assistantName] is required
  /// [instructions] and [description] are optional
  /// [guidId] is an optional tracking GUID
  Future<AssistantModel> createAssistant({
    required String assistantName,
    String? instructions,
    String? description,
    String? guidId,
  });

  /// Updates an existing AI assistant
  ///
  /// [assistantId] is required to identify which assistant to update
  /// [assistantName] is required as the new name
  /// [instructions] and [description] are optional updated values
  /// [xJarvisGuid] is an optional tracking GUID
  Future<AssistantModel> updateAssistant({
    required String assistantId,
    required String assistantName,
    String? instructions,
    String? description,
    String? xJarvisGuid,
  });

  /// Deletes an existing AI assistant
  ///
  /// [assistantId] is required to identify which assistant to delete
  /// [xJarvisGuid] is an optional tracking GUID
  Future<bool> deleteAssistant({
    required String assistantId,
    String? xJarvisGuid,
  });

  /// Links a knowledge base to an assistant
  ///
  /// [assistantId] is required to identify the assistant
  /// [knowledgeId] is required to identify the knowledge base
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is an optional tracking GUID
  ///
  /// Returns true on successful linking
  Future<bool> linkKnowledgeToAssistant({
    required String assistantId,
    required String knowledgeId,
    String? accessToken,
    String? xJarvisGuid,
  });

  /// Removes a knowledge base from an assistant
  ///
  /// [assistantId] is required to identify the assistant
  /// [knowledgeId] is required to identify the knowledge base to remove
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is an optional tracking GUID
  ///
  /// Returns true on successful removal
  Future<bool> removeKnowledgeFromAssistant({
    required String assistantId,
    required String knowledgeId,
    String? accessToken,
    String? xJarvisGuid,
  });

  /// Publishes an assistant as a Telegram bot
  ///
  /// [assistantId] is required to identify the assistant
  /// [botToken] is required Telegram bot token from BotFather
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is an optional tracking GUID
  ///
  /// Returns the Telegram bot URL on successful publishing
  Future<String> publishTelegramBot({
    required String assistantId,
    required String botToken,
    String? accessToken,
    String? xJarvisGuid,
  });

  /// Validates a Telegram bot token before publishing
  ///
  /// [botToken] is required Telegram bot token from BotFather
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is an optional tracking GUID
  ///
  /// Returns a map with bot information on successful validation
  Future<Map<String, dynamic>> validateTelegramBot({
    required String botToken,
    String? accessToken,
    String? xJarvisGuid,
  });

  /// Validates Slack bot configuration before publishing
  ///
  /// [botToken] is required Slack bot token
  /// [clientId] is required Slack client ID
  /// [clientSecret] is required Slack client secret
  /// [signingSecret] is required Slack signing secret
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is optional for tracking
  ///
  /// Returns a map with bot information on successful validation
  Future<Map<String, dynamic>> validateSlackBot({
    required String botToken,
    required String clientId,
    required String clientSecret,
    required String signingSecret,
    String? accessToken,
    String? xJarvisGuid,
  });

  /// Publishes an assistant as a Slack bot
  ///
  /// [assistantId] is required to identify the assistant
  /// [botToken] is required Slack bot token
  /// [clientId] is required Slack client ID
  /// [clientSecret] is required Slack client secret
  /// [signingSecret] is required Slack signing secret
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is optional for tracking
  ///
  /// Returns the Slack bot URL on successful publishing
  Future<String> publishSlackBot({
    required String assistantId,
    required String botToken,
    required String clientId,
    required String clientSecret,
    required String signingSecret,
    String? accessToken,
    String? xJarvisGuid,
  });
}
