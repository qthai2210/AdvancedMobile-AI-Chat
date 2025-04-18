import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/data/models/chat/conversation_request_params.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:dio/dio.dart';

class ConversationApiService {
  final ApiService _apiService = sl.get<ApiService>();

  ConversationApiService() {
    // Set the base URL for the Dio instance
    _apiService.dio.options.baseUrl = '${ApiConfig.jarvisBaseUrl}/ai-chat';
  }

  // Get user's conversations
  Future<Map<String, dynamic>> getConversations({
    // required String accessToken,
    required ConversationRequestParams params,
    // int? limit,
    // int? assistantId,

    // String? cursor,
    // required String assistantModel,
    String? xJarvisGuid,
  }) async {
    // Build query parameters
    final queryParams = <String, dynamic>{};

    if (params.limit != null) queryParams['limit'] = params.limit;
    if (params.assistantId != null)
      queryParams['assistantId'] = params.assistantId;
    if (params.cursor != null) queryParams['cursor'] = params.cursor;
    queryParams['assistantModel'] = params.assistantModel;

    // Get the access token from secure storage
    final accessToken = await SecureStorageUtil().getAccessToken();

    try {
      final response = await _apiService.dio.get(
        '/ai-chat/conversations',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            // 'x-jarvis-guid': xJarvisGuid,
          },
        ),
      );

      return _apiService.handleResponse<Map<String, dynamic>>(
        response,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      final exception = _apiService.handleError(e);
      throw exception;
    }
  }

  // Get conversation by ID
  Future<Map<String, dynamic>> getConversationById({
    required String accessToken,
    required String conversationId,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/ai-chat/conversations/$conversationId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        ),
      );

      return _apiService.handleResponse<Map<String, dynamic>>(
        response,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      final exception = _apiService.handleError(e);
      throw exception;
    }
  }

  // Delete conversation
  Future<void> deleteConversation({
    required String accessToken,
    required String conversationId,
  }) async {
    try {
      final response = await _apiService.dio.delete(
        '/ai-chat/conversations/$conversationId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      _apiService.handleResponse<void>(
        response,
        (_) {}, // No data to return for successful delete
      );
    } catch (e) {
      final exception = _apiService.handleError(e);
      throw exception;
    }
  }

  // Get conversation history
  Future<Map<String, dynamic>> getConversationHistory({
    required String conversationId,
    String? cursor,
    int? limit,
    AssistantId? assistantId,
    required AssistantModel assistantModel,
    String? xJarvisGuid,
  }) async {
    // Build query parameters
    final queryParams = <String, dynamic>{
      'assistantModel': assistantModel.toString(),
    };

    if (cursor != null) queryParams['cursor'] = cursor;
    if (limit != null) queryParams['limit'] = limit;
    if (assistantId != null)
      queryParams['assistantId'] = assistantId.toString();

    // Get the access token from secure storage
    final accessToken = await SecureStorageUtil().getAccessToken();

    try {
      final response = await _apiService.dio.get(
        '/conversations/$conversationId/messages',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            if (xJarvisGuid != null) 'x-jarvis-guid': xJarvisGuid,
          },
        ),
      );

      return _apiService.handleResponse<Map<String, dynamic>>(
        response,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      final exception = _apiService.handleError(e);
      throw exception;
    }
  }
}
