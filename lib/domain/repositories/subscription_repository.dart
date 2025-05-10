import 'package:aichatbot/domain/models/subscription_models.dart';

/// Repository interface for subscription-related operations
abstract class SubscriptionRepository {
  /// Fetches the user's current subscription information
  ///
  /// Returns a [SubscriptionModel] containing subscription details
  /// Optional [xJarvisGuid] can be provided for specific user context
  Future<SubscriptionModel> getUserSubscription({String? xJarvisGuid});
}
