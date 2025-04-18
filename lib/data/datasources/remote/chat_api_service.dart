import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/core/network/api_service_factory.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:dio/dio.dart';
import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/data/models/chat/message_request_model.dart';
import 'package:aichatbot/data/models/chat/message_response_model.dart';
import 'package:aichatbot/data/models/chat/custom_bot_message_model.dart';

class ChatApiService {
  //final ApiService _apiService = sl.get<ApiService>();
  final Dio _dio;
  final ApiService _apiService;
  ChatApiService()
      : _dio = ApiServiceFactory.createJarvisDio(),
        _apiService = sl.get<ApiService>() {
    // Set the base URL for the Dio instance
    //_apiService.dio.options.baseUrl = ApiConfig.jarvisBaseUrl;
  }

  Future<MessageResponseModel> sendMessage({
    required MessageRequestModel request,
  }) async {
    const endpoint = '/ai-chat/messages';

    try {
      // Get the access token from secure storage
      final accessToken = await SecureStorageUtil().getAccessToken();
      // Create headers for the request with authentication
      if (accessToken == null) {
        throw UnauthorizedException('Access token is null');
      }
      final headers = await _apiService.createAuthHeader();
      headers['Content-Type'] = 'application/json';
      print('Headers123: $headers');
      final response = await _dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: headers,
          validateStatus: (status) =>
              true, // Accept all status codes to handle errors manually
        ),
      );
      print('Response123: ${response.data}');
      return _apiService.handleResponse<MessageResponseModel>(
        response,
        (data) => MessageResponseModel.fromJson(data),
      );
    } catch (e) {
      throw _apiService.handleError(e);
    }
  }

  /// Sends a message to a custom bot and returns the response
  ///
  /// [request] The custom bot message request to be sent
  Future<CustomBotMessageResponse> chatWithBot({
    required CustomBotMessageRequest request,
  }) async {
    const endpoint = '/ai-chat/messages';
    try {
      // Get the access token from secure storage and create headers
      final accessToken = await SecureStorageUtil().getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('Access token is null');
      }

      final headers = await _apiService.createAuthHeader();
      headers['Content-Type'] = 'application/json';

      print('Custom Bot Headers: $headers');

      final response = await _dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: headers,
          validateStatus: (status) =>
              true, // Accept all status codes to handle errors manually
        ),
      );

      print('Custom Bot Response: ${response.data}');

      return _apiService.handleResponse<CustomBotMessageResponse>(
        response,
        (data) => CustomBotMessageResponse.fromJson(data),
      );
    } catch (e) {
      throw _apiService.handleError(e);
    }
  }
}
