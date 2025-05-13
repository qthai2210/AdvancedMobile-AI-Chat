import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/core/network/api_service_factory.dart';
import 'package:aichatbot/data/models/auth/user_profile_model.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:dio/dio.dart';

/// Service for fetching user profile information from the API
class UserProfileApiService {
  final Dio _dio;
  final ApiService _apiService;

  /// Creates a new instance of [UserProfileApiService]
  UserProfileApiService()
      : _dio = ApiServiceFactory.createJarvisDio(),
        _apiService = sl.get<ApiService>();

  /// Fetches the user's profile from the /auth/me endpoint
  ///
  /// Requires an access token and optional x-jarvis-guid
  /// Returns a [UserProfileModel] with user data
  Future<UserProfileModel> getUserProfile({String? xJarvisGuid}) async {
    const endpoint = '/auth/me';

    try {
      // Get the access token from secure storage
      final accessToken = await SecureStorageUtil().getAccessToken();

      // Create headers for the request with authentication and optional custom GUID
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };

      // Add authorization token if available
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      } else {
        throw UnauthorizedException('Authentication token is required');
      }

      // Add custom GUID if provided
      if (xJarvisGuid != null && xJarvisGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = xJarvisGuid;
      }

      AppLogger.d('Making request to $endpoint with headers: $headers');

      // Make the API call
      final response = await _dio.get(
        endpoint,
        options: Options(headers: headers),
      );

      AppLogger.d('Response received: ${response.statusCode}');
      AppLogger.d('Response body: ${response.data}');

      // Process the response
      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to fetch user profile: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('DioException in UserProfileApiService.getUserProfile: $e');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Authentication failed');
      } else {
        throw ServerException(
          'Network error: ${e.message}',
        );
      }
    } catch (e) {
      AppLogger.e('Error in UserProfileApiService.getUserProfile: $e');
      throw ServerException('Unexpected error: $e');
    }
  }
}
