import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:dio/dio.dart';
import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/data/models/chat/message_request_model.dart';
import 'package:aichatbot/data/models/chat/message_response_model.dart';

class ChatApiService {
  final ApiService _apiService = sl.get<ApiService>();

  ChatApiService() {
    // Set the base URL for the Dio instance
    _apiService.dio.options.baseUrl = ApiConfig.jarvisBaseUrl;
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
      final headers = _apiService.createAuthHeader(accessToken);
      headers['Content-Type'] = 'application/json';
      print('Headers123: $headers');
      final response = await _apiService.dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: headers,
          validateStatus: (status) =>
              true, // Accept all status codes to handle errors manually
        ),
      );

      return _apiService.handleResponse<MessageResponseModel>(
        response,
        (data) => MessageResponseModel.fromJson(data),
      );
    } catch (e) {
      throw _apiService.handleError(e);
    }
  }
}
