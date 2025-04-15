import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/data/models/knowledge/create_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_list_response.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
import 'package:aichatbot/data/models/knowledge/get_knowledge_params.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:dio/dio.dart';

/// Service for interacting with Knowledge-related API endpoints
class KnowledgeApiService {
  final ApiService _apiService = sl.get<ApiService>();

  /// Creates a new instance of [KnowledgeApiService]
  KnowledgeApiService() {
    // Set the base URL for the Dio instance
    _apiService.dio.options.baseUrl = ApiConfig.knowledgeUrl;
    _apiService.addAuthHeader();
  }

  /// Fetches knowledge items from the API based on the provided parameters
  Future<KnowledgeListResponse> getKnowledges(GetKnowledgeParams params) async {
    try {
      // Prepare headers - including the Authorization token and optional x-jarvis-guid
      //  final headers = <String, dynamic>{};

      // Add authorization token if available
      //final prefs = await sl.getAsync();
      // final token = prefs.getString('token');
      // if (token != null && token.isNotEmpty) {
      //   headers['Authorization'] = 'Bearer $token';
      // }

      // Add x-jarvis-guid if available
      // final guid = prefs.getString('x-jarvis-guid');
      // if (guid != null && guid.isNotEmpty) {
      //   headers['x-jarvis-guid'] = guid;
      // }

      // Log the request
      AppLogger.d(
          "Fetching knowledges from ${_apiService.dio.options.baseUrl}/kb-core/v1/knowledge");

      // Make the API call
      final response = await _apiService.dio.get(
        '/kb-core/v1/knowledge',
        //queryParameters: params.toQueryParameters(),
        // options: Options(headers: headers),
      );

      // Log the response
      AppLogger.i(
          'Knowledge response received with ${response.data['data']?.length ?? 0} items');

      // Parse and return the response
      return KnowledgeListResponse.fromJson(response.data);
    } catch (e) {
      AppLogger.e('Error fetching knowledges: $e');
      rethrow;
    }
  }

  /// Creates a new knowledge base with the provided parameters
  ///
  /// [params] contains the required knowledge name and optional description
  /// Returns the created [KnowledgeModel] on success
  Future<KnowledgeModel> createKnowledge(CreateKnowledgeParams params) async {
    try {
      // Prepare headers for the x-jarvis-guid if provided
      final headers = <String, dynamic>{};
      if (params.xJarvisGuid != null && params.xJarvisGuid!.isNotEmpty) {
        headers['x-jarvis-guid'] = params.xJarvisGuid;
      }

      // Log the request
      AppLogger.d('Creating knowledge base with name: ${params.knowledgeName}');

      // Make the API call
      final response = await _apiService.dio.post(
        '/kb-core/v1/knowledge',
        data: params.toJson(),
        options: Options(headers: headers.isNotEmpty ? headers : null),
      );

      // Log the response
      AppLogger.i('Knowledge base created successfully: ${response.data}');

      // Parse and return the created knowledge model
      return KnowledgeModel.fromJson(response.data);
    } catch (e) {
      AppLogger.e('Error creating knowledge base: $e');
      rethrow;
    }
  }

  /// Deletes a knowledge base with the provided ID
  ///
  /// [id] - The ID of the knowledge base to delete
  /// [xJarvisGuid] - Optional GUID for tracking purposes
  /// Returns a boolean indicating success
  Future<bool> deleteKnowledge(String id, {String? xJarvisGuid}) async {
    try {
      // Prepare headers for the x-jarvis-guid if provided
      final headers = <String, dynamic>{};
      if (xJarvisGuid != null && xJarvisGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = xJarvisGuid;
      }

      // Log the request
      AppLogger.d('Deleting knowledge base with ID: $id');

      // Make the API call
      final response = await _apiService.dio.delete(
        '/kb-core/v1/knowledge/$id',
        options: Options(headers: headers.isNotEmpty ? headers : null),
      );

      // Log the response
      AppLogger.i(
          'Knowledge base deleted successfully, status code: ${response.statusCode}');

      // Return success based on status code (200 is success)
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.e('Error deleting knowledge base: $e');
      rethrow;
    }
  }
}
