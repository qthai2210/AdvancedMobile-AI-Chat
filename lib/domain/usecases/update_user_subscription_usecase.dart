import 'package:aichatbot/domain/models/subscription_models.dart';
import 'package:aichatbot/domain/repositories/subscription_repository.dart';

/// Use case for updating the user's subscription
class UpdateUserSubscriptionUseCase {
  final SubscriptionRepository _subscriptionRepository;

  /// Creates a new instance of [UpdateUserSubscriptionUseCase]
  UpdateUserSubscriptionUseCase(this._subscriptionRepository);

  /// Updates the user subscription with the specified plan details
  ///
  /// [planName] - The name of the subscription plan ('starter' or 'pro')
  /// [isYearly] - Whether the subscription is billed yearly or monthly
  Future<SubscriptionModel> call({
    required String planName,
    required bool isYearly,
  }) {
    return _subscriptionRepository.updateUserSubscription(
      planName: planName,
      isYearly: isYearly,
    );
  }
}
