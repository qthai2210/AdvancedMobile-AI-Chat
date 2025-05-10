import 'package:aichatbot/domain/models/subscription_models.dart';
import 'package:aichatbot/domain/repositories/subscription_repository.dart';

/// Use case for fetching user subscription information
class GetUserSubscriptionUseCase {
  final SubscriptionRepository _subscriptionRepository;

  /// Creates a new instance of [GetUserSubscriptionUseCase]
  GetUserSubscriptionUseCase(this._subscriptionRepository);

  /// Executes the use case to retrieve user's subscription information
  ///
  /// Optional [xJarvisGuid] can be provided for specific user context
  Future<SubscriptionModel> call({String? xJarvisGuid}) {
    return _subscriptionRepository.getUserSubscription(
      xJarvisGuid: xJarvisGuid,
    );
  }
}
