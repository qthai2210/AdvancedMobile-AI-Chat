import 'package:aichatbot/data/datasources/remote/subscription_api_service.dart';
import 'package:aichatbot/domain/models/subscription_models.dart';
import 'package:aichatbot/domain/repositories/subscription_repository.dart';
import 'package:aichatbot/utils/logger.dart';

/// Implementation of [SubscriptionRepository]
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionApiService _subscriptionApiService;

  /// Creates a new instance of [SubscriptionRepositoryImpl]
  SubscriptionRepositoryImpl(this._subscriptionApiService);

  @override
  Future<SubscriptionModel> getUserSubscription({String? xJarvisGuid}) async {
    try {
      AppLogger.d('Fetching user subscription from API service');
      return await _subscriptionApiService.getUserSubscription(
        customGuid: xJarvisGuid,
      );
    } catch (e) {
      AppLogger.e('Error fetching user subscription: $e');
      rethrow;
    }
  }
}
