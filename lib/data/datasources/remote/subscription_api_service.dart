import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/network/api_service_factory.dart';
import 'package:aichatbot/domain/models/subscription_models.dart';
import 'package:aichatbot/domain/models/token_usage_model.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:dio/dio.dart';

/// API service for subscription-related endpoints
class SubscriptionApiService {
  final Dio _dio;

  /// Creates a new instance of [SubscriptionApiService]
  SubscriptionApiService() : _dio = ApiServiceFactory.createJarvisDio();

  // Key for storing the current subscription in local memory
  static SubscriptionModel? _currentSubscription;

  /// Fetches the user's current token usage information
  ///
  /// Returns a [SubscriptionModel] with details about the subscription plan
  /// Optional [xJarvisGuid] can be provided for specific user context
  Future<SubscriptionModel> getUserSubscription({String? xJarvisGuid}) async {
    try {
      // Define the API endpoint - now using the token usage endpoint
      const endpoint = '/tokens/usage';

      // Get the access token from secure storage
      final accessToken = await SecureStorageUtil().getAccessToken();

      // Create headers for the request
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };

      // Add authorization token if available
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      } else {
        AppLogger.w('No access token available for token usage request');
      }

      // Add custom GUID if provided
      if (xJarvisGuid != null && xJarvisGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = xJarvisGuid;
      }

      AppLogger.d('Making request to $endpoint with headers: $headers');

      // Make the API call to the new endpoint
      final response = await _dio.get(
        ApiConfig.jarvisBaseUrl + endpoint,
        options: Options(headers: headers),
      );

      // Handle the response
      if (response.statusCode == 200) {
        final responseData = response.data;
        AppLogger.d('Token usage response: $responseData');

        // Create token usage model from the response
        final tokenUsage = TokenUsageModel(
          availableTokens: responseData['availableTokens'] ?? 0,
          totalTokens: responseData['totalTokens'] ?? 0,
          unlimited: responseData['unlimited'] ?? false,
          date: responseData['date'] != null
              ? DateTime.parse(responseData['date'])
              : DateTime.now(),
        );

        // Create basic subscription model with token usage data
        final subscription = SubscriptionModel(
          name: 'basic', // Default name
          pricingDisplay: 'Free', // Default display
          price: 0.0,
          billingPeriod: 'monthly',
          isActive: true,
          features: [],
          modelAccess: [],
          tokenUsage: tokenUsage,
        );

        // Cache the subscription for future use
        _currentSubscription = subscription;

        return subscription;
      } else {
        AppLogger.e('Error fetching subscription: ${response.statusCode}');
        throw ServerException(
            'Failed to fetch subscription data: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.e('Error in SubscriptionApiService.getUserSubscription: $e');

      // If we failed to get subscription data, return a basic free subscription as fallback
      _currentSubscription = SubscriptionModel.free();
      return _currentSubscription!;
    }
  }

  /// Updates the user's subscription after a purchase
  ///
  /// [planName] - The name of the plan ('starter' or 'pro')
  /// [isYearly] - Whether the subscription is yearly or monthly
  Future<SubscriptionModel> updateUserSubscription({
    required String planName,
    required bool isYearly,
  }) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 1200));

      // Set the new subscription based on plan name
      if (planName.toLowerCase() == 'starter') {
        _currentSubscription = SubscriptionModel.starter(yearly: isYearly);
      } else {
        // Default to free if plan name not recognized
        _currentSubscription = SubscriptionModel.free();
      }

      AppLogger.d(
          'Updated subscription to: ${_currentSubscription!.name} (${_currentSubscription!.billingPeriod})');
      return _currentSubscription!;
    } catch (e) {
      AppLogger.e('Error in SubscriptionApiService.updateUserSubscription: $e');
      throw ServerException('Unexpected error: $e');
    }
  }
}
