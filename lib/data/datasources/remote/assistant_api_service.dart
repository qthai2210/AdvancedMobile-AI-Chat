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
  /// [assistantId] is required to identify which assistant to update
  /// [assistantName] is required as the new name
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
      } // Make the API call
      final response = await _dio.patch(
        '/kb-core/v1/ai-assistant/$assistantId',
        data: body,
        options: Options(headers: headers),
      );

      AppLogger.i('Update assistant response: ${response.data}');

      // Handle different response structures
      try {
        if (response.data['data'] != null) {
          // If response has a nested 'data' field
          return AssistantModel.fromJson(response.data['data']);
        } else if (response.data is Map<String, dynamic>) {
          // If the response itself is the assistant data
          return AssistantModel.fromJson(response.data);
        } else {
          throw Exception('Unexpected response format: ${response.data}');
        }
      } catch (e) {
        AppLogger.e('Error parsing assistant response: $e');
        AppLogger.e('Response was: ${response.data}');
        throw Exception('Failed to parse assistant response: $e');
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
  /// [assistantId] is required to identify which assistant to delete
  /// [xJarvisGuid] is an optional tracking GUID
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
      final response = await _apiService.dio.delete(
        '/kb-core/v1/ai-assistant/$assistantId',
        options: Options(headers: headers),
      );

      AppLogger.i('Delete assistant response: ${response.statusCode}');

      // If status code is 200, the deletion was successful
      return response.statusCode == 200;
    } on DioException catch (e) {
      AppLogger.e('Error deleting assistant: ${e.message}');
      AppLogger.e('Error response: ${e.response?.data}');
      throw Exception('Failed to delete assistant: ${e.message}');
    } catch (e) {
      AppLogger.e('Unexpected error deleting assistant: $e');
      throw Exception('Failed to delete assistant: $e');
    }
  }
}
