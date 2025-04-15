import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/core/config/api_config.dart';
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
}
