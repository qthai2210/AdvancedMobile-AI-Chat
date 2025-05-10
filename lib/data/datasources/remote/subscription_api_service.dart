import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/core/network/api_service_factory.dart';
import 'package:aichatbot/domain/models/subscription_models.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:dio/dio.dart';

/// API service for subscription-related endpoints
class SubscriptionApiService {
  final Dio _dio;
  final ApiService _apiService;

  /// Creates a new instance of [SubscriptionApiService]
  SubscriptionApiService()
      : _dio = ApiServiceFactory.createJarvisDio(),
        _apiService = sl.get<ApiService>();

  /// Fetches the user's current subscription information
  ///
  /// Returns a [SubscriptionModel] with details about the subscription plan
  /// Optional [customGuid] can be provided for specific user context
  Future<SubscriptionModel> getUserSubscription({String? customGuid}) async {
    const endpoint = '/subscriptions/me';

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
      if (customGuid != null && customGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = customGuid;
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
        return SubscriptionModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to fetch subscription: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e(
          'DioException in SubscriptionApiService.getUserSubscription: $e');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Authentication failed');
      } else {
        throw ServerException(
          'Network error: ${e.message}',
        );
      }
    } catch (e) {
      AppLogger.e('Error in SubscriptionApiService.getUserSubscription: $e');
      throw ServerException('Unexpected error: $e');
    }
  }
}
