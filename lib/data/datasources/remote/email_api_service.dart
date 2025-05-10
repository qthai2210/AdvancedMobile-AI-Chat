import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/core/network/api_service_factory.dart';
import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:dio/dio.dart';

class EmailApiService {
  final Dio _dio;
  final ApiService _apiService;

  EmailApiService()
      : _dio = ApiServiceFactory.createJarvisDio(),
        _apiService = sl.get<ApiService>();

  /// Get email reply suggestions from the AI
  Future<EmailReplySuggestionResponse> getSuggestionReplies({
    required EmailReplySuggestionRequest request,
    String? customGuid,
  }) async {
    const endpoint = '/ai-email/reply-ideas';

    try {
      // Get the access token from secure storage
      final accessToken = await SecureStorageUtil().getAccessToken();

      // Create headers for the request with authentication and optional custom GUID
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };
      // body will copy the request except model
      final body = request.toJson();
      body.remove('model');
      // Add authorization token if available
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      } else {
        throw UnauthorizedException('Authentication token is required');
      }

      // Add custom GUID if provided
      if (customGuid != null && customGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = customGuid;
      }

      AppLogger.d('Making request to $endpoint with headers: $headers');

      // Make the API call
      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );

      AppLogger.d('Response received: ${response.statusCode}');

      // Process the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return EmailReplySuggestionResponse.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to get email reply suggestions: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('DioException in EmailApiService.getSuggestionReplies: $e');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Authentication failed');
      } else {
        throw ServerException(
          'Network error: ${e.message}',
        );
      }
    } catch (e) {
      AppLogger.e('Error in EmailApiService.getSuggestionReplies: $e');
      throw ServerException('Unexpected error: $e');
    }
  }
}
