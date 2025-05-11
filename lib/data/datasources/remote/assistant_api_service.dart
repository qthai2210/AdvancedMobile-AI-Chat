import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/core/network/api_service_factory.dart';
import 'package:aichatbot/data/models/assistant/assistant_list_response.dart';
import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/data/models/assistant/get_assistants_params.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:dio/dio.dart';

/// API service for interacting with Assistant endpoints
class AssistantApiService {
  final ApiService _apiService;
  final Dio _dio;

  /// Creates a new instance of [AssistantApiService]
  AssistantApiService()
      : _dio = ApiServiceFactory.createKnowledgeDio(),
        _apiService = sl.get<ApiService>() {
    // Set the base URL for the Dio instance
  }

  /// Retrieves a list of AI assistants with optional filtering and pagination
  ///
  /// Parameters match the API specification from APIdog:
  /// - [params] - Query parameters for filtering and pagination
  Future<AssistantListResponse> getAssistants(
      GetAssistantsParams params) async {
    try {
      // Prepare headers with optional GUID

      if (params.xJarvisGuid != null && params.xJarvisGuid!.isNotEmpty) {
        // add x-jarvis-guid to headers
        _apiService.dio.options.headers = {
          ..._apiService.dio.options.headers,
          'x-jarvis-guid': params.xJarvisGuid
        };
      }
      AppLogger.i("dio headers ${_apiService.dio.options.headers}");
      AppLogger.i(
          "dio endpoint ${_apiService.dio.options.baseUrl}/kb-core/v1/ai-assistant");
      final response = await _dio.get(
        '/kb-core/v1/ai-assistant',
        queryParameters: params.toQueryParameters(),
        // options: Options(headers: headers),
      );
      AppLogger.i('Response received: ${response.data}');

      return AssistantListResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('Error fetching assistants: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  /// Retrieves a specific AI assistant by ID
  Future<AssistantModel> getAssistantById(String assistantId,
      {String? xJarvisGuid}) async {
    try {
      // Prepare headers with optional GUID
      final headers = <String, dynamic>{};
      if (xJarvisGuid != null && xJarvisGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = xJarvisGuid;
      }

      final response = await _dio.get(
        '/api/v1/ai-assistants/$assistantId',
        options: Options(headers: headers),
      );

      return AssistantModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('Error fetching assistant: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  /// Creates a new assistant
  ///
  /// Makes a POST request to the create assistant endpoint
  ///
  /// Returns the created [AssistantModel] on success
  Future<AssistantModel> createAssistant({
    required String assistantName,
    String? instructions,
    String? description,
    String? guidId,
  }) async {
    try {
      // Prepare headers with optional GUID
      final headers = <String, dynamic>{};
      if (guidId != null && guidId.isNotEmpty) {
        headers['x-jarvis-guid'] = guidId;
      }

      // Prepare request body
      final Map<String, dynamic> body = {
        'assistantName': assistantName,
      };

      // Add optional fields if they exist
      if (instructions != null && instructions.isNotEmpty) {
        body['instructions'] = instructions;
      }

      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      // Make the API call
      final response = await _dio.post(
        '/kb-core/v1/ai-assistant',
        data: body,
        options: Options(headers: headers),
      );

      AppLogger.i('Create assistant response: ${response.data}');

      // Check status code and parse response
      if (response.statusCode == 201) {
        return AssistantModel.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create assistant: Unexpected status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.e('Error creating assistant: ${e.message}');
      AppLogger.e('Error response: ${e.response?.data}');
      throw Exception('Failed to create assistant: ${e.message}');
    } catch (e) {
      AppLogger.e('Unexpected error creating assistant: $e');
      throw Exception('Failed to create assistant: $e');
    }
  }

  /// Updates an existing assistant
  ///
  /// Makes a PUT request to the update assistant endpoint
  ///
  /// [assistantId] is required to identify which assistant to update  /// [assistantName] is required as the new name
  /// [instructions] and [description] are optional updated values
  /// [xJarvisGuid] is an optional tracking GUID
  ///
  /// Returns the updated [AssistantModel] on success
  Future<AssistantModel> updateAssistant({
    required String assistantId,
    required String assistantName,
    String? instructions,
    String? description,
    String? xJarvisGuid,
  }) async {
    try {
      // Prepare headers with optional GUID
      final headers = <String, dynamic>{};
      if (xJarvisGuid != null && xJarvisGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = xJarvisGuid;
      }

      // Prepare request body
      final Map<String, dynamic> body = {
        'assistantName': assistantName,
      };

      // Add optional fields if they exist
      if (instructions != null) {
        body['instructions'] = instructions;
      }

      if (description != null) {
        body['description'] = description;
      }

      // Make the API call
      final response = await _dio.patch(
        '/kb-core/v1/ai-assistant/$assistantId',
        data: body,
        options: Options(headers: headers),
      );

      AppLogger.i('Update assistant response: ${response.statusCode}');

      // Handle 204 No Content response
      if (response.statusCode == 204) {
        // For 204 No Content, return an assistant model with just the required fields
        // since update was successful but no content was returned
        AppLogger.i(
            'Received 204 No Content response - update successful but no content returned');
        return AssistantModel(
          id: assistantId,
          assistantName: assistantName,
          openAiAssistantId:
              '', // Using default empty string as we don't have this info
          instructions: instructions,
          description: description,
        );
      }

      // Handle response with content
      if (response.data != null) {
        try {
          if (response.data['data'] != null) {
            // If response has a nested 'data' field
            return AssistantModel.fromJson(response.data['data']);
          } else if (response.data is Map<String, dynamic>) {
            // If the response itself is the assistant data
            return AssistantModel.fromJson(response.data);
          }

          // If we got here, the response format wasn't recognized
          AppLogger.w(
              'Unexpected response format but update likely successful: ${response.data}');
          return AssistantModel(
            id: assistantId,
            assistantName: assistantName,
            openAiAssistantId: '', // Using default empty string
            instructions: instructions,
            description: description,
          );
        } catch (e) {
          AppLogger.e('Error parsing assistant response: $e');
          AppLogger.e('Response was: ${response.data}');
          throw Exception('Failed to parse assistant response: $e');
        }
      } else {
        // Empty response but not a 204 status
        AppLogger.w(
            'Received empty response with status ${response.statusCode}');
        return AssistantModel(
          id: assistantId,
          assistantName: assistantName,
          openAiAssistantId: '',
          instructions: instructions,
          description: description,
        );
      }
    } on DioException catch (e) {
      AppLogger.e('Error updating assistant: ${e.message}');
      AppLogger.e('Error response: ${e.response?.data}');
      throw Exception('Failed to update assistant: ${e.message}');
    } catch (e) {
      AppLogger.e('Unexpected error updating assistant: $e');
      throw Exception('Failed to update assistant: $e');
    }
  }

  /// Deletes an existing assistant
  ///
  /// Makes a DELETE request to the delete assistant endpoint
  ///
  /// [assistantId] is required to identify which assistant to delete  /// [xJarvisGuid] is an optional tracking GUID
  ///
  /// Returns true on successful deletion
  Future<bool> deleteAssistant({
    required String assistantId,
    String? xJarvisGuid,
  }) async {
    try {
      // Prepare headers with optional GUID
      final headers = <String, dynamic>{};
      if (xJarvisGuid != null && xJarvisGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = xJarvisGuid;
      }

      // Make the API call
      final response = await _dio.delete(
        '/kb-core/v1/ai-assistant/$assistantId',
        options: Options(headers: headers),
      );

      AppLogger.i('Delete assistant response: ${response.statusCode}');

      // If status code is 200 or 204, the deletion was successful
      // 204 means "No Content" which is a common response for DELETE operations
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      AppLogger.e('Error deleting assistant: ${e.message}');
      AppLogger.e('Error response: ${e.response?.data}');
      throw Exception('Failed to delete assistant: ${e.message}');
    } catch (e) {
      AppLogger.e('Unexpected error deleting assistant: $e');
      throw Exception('Failed to delete assistant: $e');
    }
  }

  /// Links a knowledge base to an assistant
  ///
  /// Makes a PUT request to link a knowledge base to an assistant
  ///
  /// [assistantId] is required to identify the assistant
  /// [knowledgeId] is required to identify the knowledge base
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is an optional tracking GUID
  ///
  /// Returns true on successful linking (status code 204)
  Future<bool> linkKnowledgeToAssistant({
    required String assistantId,
    required String knowledgeId,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    try {
      // Prepare headers with optional authorization and GUID
      final headers = <String, dynamic>{};
      if (xJarvisGuid != null && xJarvisGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = xJarvisGuid;
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      // Log the request details
      AppLogger.i('Linking knowledge $knowledgeId to assistant $assistantId');

      // Construct the endpoint URL
      final endpoint =
          '/kb-core/v1/ai-assistant/$assistantId/knowledges/$knowledgeId';

      // Make the API call
      final response = await _dio.post(
        endpoint,
        options: Options(headers: headers),
      );

      AppLogger.i('Link knowledge response: ${response.statusCode}');

      // For this endpoint, 204 No Content indicates success
      return response.statusCode == 204;
    } on DioException catch (e) {
      AppLogger.e('Error linking knowledge to assistant: ${e.message}');
      AppLogger.e('Error response: ${e.response?.data}');
      throw Exception('Failed to link knowledge to assistant: ${e.message}');
    } catch (e) {
      AppLogger.e('Unexpected error linking knowledge to assistant: $e');
      throw Exception('Failed to link knowledge to assistant: $e');
    }
  }

  /// Removes a knowledge base from an assistant
  ///
  /// Makes a DELETE request to remove a knowledge base from an assistant
  ///
  /// [assistantId] is required to identify the assistant
  /// [knowledgeId] is required to identify the knowledge base to remove
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is an optional tracking GUID
  ///
  /// Returns true on successful removal (status code 204)
  Future<bool> removeKnowledgeFromAssistant({
    required String assistantId,
    required String knowledgeId,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    try {
      // Prepare headers with optional authorization and GUID
      final headers = <String, dynamic>{};
      if (xJarvisGuid != null && xJarvisGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = xJarvisGuid;
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      // Log the request details
      AppLogger.i(
          'Removing knowledge $knowledgeId from assistant $assistantId');

      // Construct the endpoint URL
      final endpoint =
          '/kb-core/v1/ai-assistant/$assistantId/knowledges/$knowledgeId';

      // Make the API call
      final response = await _dio.delete(
        endpoint,
        options: Options(headers: headers),
      );

      AppLogger.i('Remove knowledge response: ${response.statusCode}');

      // For this endpoint, 204 No Content indicates success
      return response.statusCode == 204;
    } on DioException catch (e) {
      AppLogger.e('Error removing knowledge from assistant: ${e.message}');
      AppLogger.e('Error response: ${e.response?.data}');
      throw Exception(
          'Failed to remove knowledge from assistant: ${e.message}');
    } catch (e) {
      AppLogger.e('Unexpected error removing knowledge from assistant: $e');
      throw Exception('Failed to remove knowledge from assistant: $e');
    }
  }

  /// Publishes an assistant as a Telegram bot
  ///
  /// Makes a POST request to the Telegram bot integration endpoint
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
  }) async {
    try {
      // Prepare headers with optional values
      final headers = <String, dynamic>{};

      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      if (xJarvisGuid != null && xJarvisGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = xJarvisGuid;
      }

      // Prepare request body with the bot token
      final body = {
        'botToken': botToken,
      };

      AppLogger.i('Publishing assistant $assistantId as Telegram bot');

      // Make the API call
      final response = await _dio.post(
        '/kb-core/v1/bot-integration/telegram/publish/$assistantId',
        data: body,
        options: Options(headers: headers),
      );

      // Log the response for debugging
      AppLogger.i('Response received: ${response.data}');

      // Extract the redirect URL from the response
      if (response.data is Map && response.data.containsKey('redirect')) {
        return response.data['redirect'];
      } else {
        throw Exception('Invalid response format: missing redirect URL');
      }
    } on DioException catch (e) {
      AppLogger.e('Error publishing Telegram bot: ${e.message}');
      rethrow;
    } catch (e) {
      AppLogger.e('Unexpected error publishing Telegram bot: $e');
      rethrow;
    }
  }
}
