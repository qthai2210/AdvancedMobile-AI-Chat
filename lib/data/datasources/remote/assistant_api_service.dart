import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/data/models/assistant/assistant_list_response.dart';
import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/data/models/assistant/get_assistants_params.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:dio/dio.dart';

/// API service for interacting with Assistant endpoints
class AssistantApiService {
  final ApiService _apiService = sl.get<ApiService>();

  /// Creates a new instance of [AssistantApiService]
  AssistantApiService() {
    // Set the base URL for the Dio instance
    _apiService.dio.options.baseUrl = ApiConfig.knowledgeUrl;
    // awaits _apiService.createAuthHeader();
    _apiService.addAuthHeader();
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
          "dio endpoint ${_apiService.dio.options.baseUrl}/kb-core/v1/ai-assistants");
      final response = await _apiService.dio.get(
        '/kb-core/v1/ai-assistants',
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

      final response = await _apiService.dio.get(
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
}
