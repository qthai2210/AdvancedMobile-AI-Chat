import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/domain/models/subscription_models.dart';
import 'package:aichatbot/utils/logger.dart';

/// API service for subscription-related endpoints
class SubscriptionApiService {
  /// Creates a new instance of [SubscriptionApiService]
  SubscriptionApiService();
  // Key for storing the current subscription in local memory
  static SubscriptionModel? _currentSubscription;

  /// Fetches the user's current subscription information
  ///
  /// Returns a [SubscriptionModel] with details about the subscription plan
  /// Optional [customGuid] can be provided for specific user context
  Future<SubscriptionModel> getUserSubscription({String? customGuid}) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Return cached subscription if available
      if (_currentSubscription != null) {
        AppLogger.d(
            'Returning cached subscription: ${_currentSubscription!.name}');
        return _currentSubscription!;
      }

      // Mock the free plan as default
      _currentSubscription = SubscriptionModel.free();

      AppLogger.d('Returning mocked free subscription');
      return _currentSubscription!;
    } catch (e) {
      AppLogger.e('Error in SubscriptionApiService.getUserSubscription: $e');
      throw ServerException('Unexpected error: $e');
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
